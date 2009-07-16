# HostMachine is used to interface with a host machine
# 
# == Notes
# A host machine may be either another machine or the localhost.
# By supporting localhost, it is likely that the process will
# be on a different core than the current processes.
#
# Once HostMachine opens an ssh connection, it does not close
# the connection until a disconnect() is invoked.
class HostMachine
  attr_accessor :uuid, :dir, :controller
  attr_reader :name, :machine, :user, :port
  
  class << self
    attr_accessor :connection_mutex
  end
  @connection_mutex = Mutex.new
  
  # @param [String] host_string describes the host to connect to.
  #  The format is "{user{:password}@}machine{:port}"
  # @param [Logger] logger the logger to use
  # @param [UserChoices,Hash] choices
  # @option choices [Array<String>] :keys (['~/.ssh/id_dsa', '~/.ssh/id_rsa']) array of ssh key file names.
  def initialize(host_string, logger, choices)
    @logger = logger
    @choices = choices
    @machine = 'localhost'
    @user = ENV['USER']
    @port = 9000
    keys = choices[:keys] || ["~/.ssh/id_dsa", "~/.ssh/id_rsa"]
    @password = {:keys => keys.collect{|name| name.gsub('~', ENV['HOME'])}.select{|name| File.exist?(name)}}
    case host_string
    when /^(\S+)\:(\S+)\@(\S+)\:(\d+)$/
      @user = $1
      @password = {:password => $2}
      @machine = $3
      @port = $4.to_i
    when /^(\S+)\:(\S+)\@(\S+)$/
      @user = $1
      @password = {:password => $2}
      @machine = $3
    when /^(\S+)\@(\S+)\:(\d+)$/
      @user = $1
      @machine = $2
      @port = $3.to_i
    when /^(\S+)\@(\S+)$/
      @user = $1
      @machine = $2
    when /^(\S+)\:(\d+)$/
      @machine = $1
      @port = $2.to_i
    when /^(\S+)$/
      @machine = $1
    end
    @name = "#{user}@#{machine}:#{port}"
    @ssh = nil
    @logger.debug { self.pretty_inspect }
  end
  
  # Connect to the host, execute the given block, then disconnect from the host
  # @yield [HostMachine]
  # @example
  # host_machine = HostMachine.new('localhost', @logger)
  # host_machine.session do |host|
  #   host.upload(local_dir, "#{host.dir}/#{File.basename(local_dir)}")
  #   @logger.debug { host.sh("ls -lR #{host.dir}") }
  # end
  def session(&block)
    begin
      # this is ugly but apparently net-ssh can fail public_key authentication
      # when ran in parallel.
      HostMachine.connection_mutex.synchronize do
        connect
      end
      yield self
    rescue Exception => e
      @logger.error { e }
      @logger.error { e.backtrace.join("\n") }
      raise e
    ensure
      disconnect
    end
  end
  
  # upload a directory structure to the host machine.
  # @param [String] local_src the source directory on the local machine
  # @param [String] remote_dest the destination directory on the host machine
  # @raise [Exception] if the files are not copied
  def upload(local_src, remote_dest)
    @logger.debug { "upload(\"#{local_src}\", \"#{remote_dest}\")" }
    result = nil
    unless @ssh.nil?
      begin
        @ssh.scp.upload!(local_src, remote_dest, :recursive => true) do |ch, name, sent, total|
          @logger.debug { "#{name}: #{sent}/#{total}" }
        end
        @ssh.loop
      rescue Exception => e
        # only raise the exception if the files differ
        raise e unless same_files?(local_src, remote_dest)
      end
    end
  end

  # download a directory structure from the host machine.
  # @param [String] remote_src the source directory on the host machine
  # @param [String] local_dest the destination directory on the local machine
  # @raise [Exception] if the files are not copied
  def download(remote_src, local_dest)
    result = nil
    unless @ssh.nil?
      begin
        @ssh.scp.download!(local_src, remote_dest, :recursive => true) do |ch, name, sent, total|
          @logger.debug { "#{name}: #{sent}/#{total}" }
        end
        @ssh.loop
      rescue Exception => e
        # only raise the exception if the files differ
        raise e unless same_files?(local_dest, remote_src)
      end
    end
  end

  # run a command on the host machine
  # Note that the environment on the host machine is the default environment instead
  # of the user's environment.  So by default we try to source ~/.profile and ~/.bashrc
  #
  # @param [String] command the command to run
  # @param [Hash] opts
  # @option opts [Array<String>] :source (['~/.profile', '~/.bashrc']) array of files to source.
  # @return [String, nil] the output from running the command
  def sh(command, opts={})
    unless @ssh.nil?
      opts[:source] = ['~/.profile', '~/.bashrc'] if opts[:source].blank?
      result = nil
      commands = pre_commands(opts[:source])
      commands << command
      command_line = commands.join(' && ')
      @logger.debug { "sh: \"#{command_line}\""}
      result = @ssh.exec!(command_line)
      @logger.debug { "=> #{result}" }
    end
    result
  end
  
  private
  
  def pre_commands(sources)
    if @pre_commands.nil?
      @pre_commands = []
      unless @ssh.nil?
        sources.each do |name|
          ls_out = @ssh.exec!("ls #{name}")
          @pre_commands << "source #{name}" if ls_out =~ /^\s*\S+\/#{File.basename(name)}\s*$/
        end
      end
    end
    @pre_commands.clone
  end
  
  # connect to the host machine
  # note, you should not need to call the connect method.
  # @see {#session}
  def connect
    if @ssh.nil?
      options = @password.merge({
        :timeout=>2, 
        :auth_methods => %w(publickey hostbased password)
        })
      options = @password.merge({:verbose=>Logger::DEBUG}) if @choices[:ssh_debug]
      @logger.debug { "connect: @machine=>#{@machine}, @user=>#{@user}, options=>#{options.inspect}" }
      @ssh = Net::SSH.start(@machine, @user, options)
      # @ssh.forward.local(@port, @machine, @port)
    end
  end
  
  # disconnect from the host machine.
  # note, you should not need to call the disconnect method.
  # @see {#session}
  def disconnect
    if @ssh
      @ssh.close
      @ssh = nil
    end
  end

  # Does the local directory tree and the remote directory tree contain the same files?
  # Calculates a MD5 hash for each file then compares the hashes
  # @param [String] local_path local directory
  # @param [String] remote_path remote directory
  # @return [Boolean] asserted if the files in both directory trees are identical
  def same_files?(local_path, remote_path)
    result = false
    unless @ssh.nil?
      remote_md5 = @ssh.exec!(md5_command_line(remote_path))
      local_md5 = `#{md5_command_line(local_path)}`
      @logger.debug { "same_files? local_md5 => #{local_md5}, remote_md5 => #{remote_md5}"}
      result = (remote_md5 == local_md5)
    end
    result
  end
  
  # @param [String] dirname the directory name to use in building the md5 command line
  # @return [String] the command line for finding the md5 hash value
  def md5_command_line(dirname)
    line = "cat \`find #{dirname} -type f | sort\` | ruby -e \"require 'digest/md5';puts Digest::MD5.hexdigest(STDIN.read)\""
    @logger.debug { line }
    line
  end
  
end
