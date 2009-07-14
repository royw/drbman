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
  
  # @param [String] host_string describes the host to connect to.
  #  The format is "{user{:password}@}machine{:port}"
  # @param [Logger] logger the logger to use
  def initialize(host_string, logger)
    @logger = logger
    @machine = 'localhost'
    @user = ENV['USER']
    @port = 9000
    @password = {:keys => ['~/.ssh/id_dsa']}
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
    connect
    yield self
    disconnect
  end
  
  # upload a directory structure to the host machine.
  # @param [String] local_src the source directory on the local machine
  # @param [String] remote_dest the destination directory on the host machine
  # @raise [Exception] if the files are not copied
  def upload(local_src, remote_dest)
    @logger.debug { "upload(\"#{local_src}\", \"#{remote_dest}\")" }
    connect
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
    connect
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
  # @options opts [Array<String>] :source array of files to source. defaults to ['~/.profile', '~/.bashrc']
  def sh(command, opts={})
    @logger.debug { "sh \"#{command}\""}
    # if opts[:source].blank?
    #   opts[:source] = ['~/.profile', '~/.bashrc']
    # end
    connect
    result = nil
    unless @ssh.nil?
      if @pre_commands.nil?
        @pre_commands = []
        opts[:source] ||= []
        opts[:source].each do |name|
          ls_out = @ssh.exec!("ls #{name}")
          @pre_commands << "source #{name}" if ls_out =~ /^\s*\S+\/#{File.basename(name)}\s*$/
        end
      end
      commands = @pre_commands.clone
      commands << command
      command_line = commands.join(' && ')
      result = @ssh.exec!(command_line)
    end
    result
  end
  
  # run a command as the superuser on the host machine
  # Note that the environment on the host machine is the default environment instead
  # of the user's environment.  So by default we try to source ~/.profile and ~/.bashrc
  #
  # @param [String] command the command to run
  # @param [Hash] opts
  # @options opts [Array<String>] :source array of files to source. defaults to ['~/.profile', '~/.bashrc']
  def sudo(command, opts={})
    @logger.debug { "sudo \"#{command}\""}
    # if opts[:source].blank?
    #   opts[:source] = ['~/.profile', '~/.bashrc']
    # end
    connect
    result = nil
    unless @ssh.nil?
      buf = []
      @ssh.open_channel do |channel|
        if @pre_commands.nil?
          @pre_commands = []
          opts[:source] ||= []
          opts[:source].each do |name|
            ls_out = @ssh.exec!("ls #{name}")
            @pre_commands << "source #{name}" if ls_out =~ /^\s*\S+\/#{File.basename(name)}\s*$/
          end
        end
        commands = @pre_commands.clone
        commands << "sudo -p 'sudo password: ' #{command}"
        command_line = commands.join(' && ')
        channel.exec(command_line) do |ch, success|
          ch.on_data do |ch, data|
            if data =~ /sudo password: /
              ch.send_data("#{@password[:password]}\n")
            else
              buf << data
            end
          end
        end
      end
      @ssh.loop
      result = buf.compact.join('')
    end
    result
  end

  # connect to the host machine
  def connect
    if @ssh.nil?
      @ssh = Net::SSH.start(@machine, @user, @password)
      # @ssh.forward.local(@port, @machine, @port)
    end
  end
  
  # disconnect from the host machine
  def disconnect
    if @ssh
      @ssh.close
      @ssh = nil
    end
  end

  private
  
  # Does the local directory tree and the remote directory tree contain the same files?
  # Calculates a MD5 hash for each file then compares the hashes
  # @param [String] local_path local directory
  # @param [String] remote_path remote directory
  def same_files?(local_path, remote_path)
    remote_md5 = @ssh.exec!(md5_command_line(remote_path))
    local_md5 = `#{md5_command_line(local_path)}`
    @logger.debug { "same_files? local_md5 => #{local_md5}, remote_md5 => #{remote_md5}"}
    remote_md5 == local_md5
  end
  
  def md5_command_line(dirname)
    line = "cat \`find #{dirname} -type f | sort\` | ruby -e \"require 'digest/md5';puts Digest::MD5.hexdigest(STDIN.read)\""
    @logger.debug { line }
    line
  end
  
end
