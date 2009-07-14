# Drbman is the drb manager
#
# == Synopsis
# Drbman will create a project directory on a host machine,
# then copy a set of files to the host machine, make sure
# a given set of gems is installed on the host machine, then
# run the drb server on the host machine.
# Drbman also supports issuing a termination command to
# the drb server on the remote machine and cleaning up
# the project by removing the files installed onto the
# host machine.
#
# == Notes
# Uses the Command design pattern
class Drbman
  # @param [Logger] logger the logger
  # @param [UserChoices,Hash] choices
  # @option choices [Array<String>] :dirs array of local directories to copy to the host machines.  REQUIRED
  # @option choices [String] :run the name of the file to run on the host machine.  REQUIRED
  #  This file should start the drb server.  Note, this file will be daemonized before running.
  # @option choices [Array<String>] :hosts array of host machine descriptions "{user{:password}@}machine{:port}"
  #  This defaults to ['localhost']
  # @option choices [Integer] :port default port number used to assign to hosts without a port number.
  #  The port number is incremented for each host.  This defaults to 9000
  # @option choices [Array<String>] :gems array of gem names to verify are installed on the host machine.
  #  Note, 'daemons' is always added to this array.
  # @yield [Drbman]
  # @example Usage
  # Drbman.new(logger, choices) do |drbman|
  #   drbman.get_object do |obj|
  #     obj.do_something
  #   end
  # end
  def initialize(logger, choices, &block)
    @logger = logger
    @user_choices = choices
    
    # @hosts[machine_description] = HostMachine instance
    @hosts = {}

    choices[:port] ||= 9000
    choices[:hosts] ||= ['localhost']
    choices[:gems] ||= []
    choices[:gems] = (choices[:gems] + ['daemons']).uniq.compact
    
    raise ArgumentError.new('Missing choices[:run]') if choices[:run].blank?
    raise ArgumentError.new('Missing choices[:hosts]') if choices[:hosts].blank?
    raise ArgumentError.new('Missing choices[:dirs]') if choices[:dirs].blank?
    
    # populate the @hosts hash.  key => host machine description, value => HostMachine instance
    port = choices[:port]
    @user_choices[:hosts].each do |host|
      host = "#{host}:#{port}" unless host =~ /\:\d+\s*$/
      @hosts[host] = HostMachine.new(host, @logger)
      port += 1
    end
    
    unless block.nil?
      setup
      begin
        @pool = DrbPool.new(@hosts, @logger)
        block.call(self)
      rescue Exception => e
        @logger.error { e }
        @logger.error { e.backtrace.join("\n") }
      ensure
        @pool.shutdown unless @pool.nil?
        shutdown
      end
    end
  end
  
  # Use an object from the pool
  # @yield [DRbObject]
  # @example Usage
  #   drbman.get_object {|obj| obj.do_something}
  def get_object(&block)
    @pool.get_object(&block)
  end
  
  private

  # setup the host machine drb servers
  def setup
    execute(:startup)
    sleep 1  # give the drb servers a little time to get running
  end
  
  # stop and remove the host machine drb servers
  def shutdown
    execute(:cleanup)
  end
  
  # @param [Symbol,String] cmd the command to run for all host machines.  Should be either :startup or :cleanup
  # @raise [ArgumentError] if cmd parameter is not :startup or :cleanup
  def execute(cmd)
    raise ArgumentError.new("invalid argument value (#{cmd.to_s}), must be either :startup or :cleanup") unless [:startup, :cleanup].include?(cmd)
    threads = []
    @hosts.each do |name, host_machine|
      host_machine.session do |host_obj|
        threads << Thread.new(host_obj) do |host|
          begin
            send(cmd, host)
          rescue Exception => e
            @logger.error { e }
            @logger.error { e.backtrace.join("\n") }
          end
        end
      end
    end
    threads.each {|thrd| thrd.join}
  end
  
  # Setup the drb server on the given host then start it
  # @param [HostMachine] host the host machine
  def startup(host)
    @logger.info { "Setting up: #{host.name}" }
    check_gems(host)
    create_directory(host)
    upload_dirs(host)
    create_controller(host)
    run_drb_server(host)
  end
  
  # Stop the drb server on the given host then remove the drb files from the host
  # @param [HostMachine] host the host machine
  def cleanup(host)
    @logger.info { "Cleaning up: #{host.name}" }
    stop_drb_server(host)
    cleanup_files(host)
  end
  
  # remove the host directory and any files in it from
  # the host machine
  # @param [HostMachine] host the host machine
  def cleanup_files(host)
    unless host.dir.blank? || (host.dir =~ /[\*\?]/)
      @logger.debug { "#{host.name}: rm -rf #{host.dir}"}
      host.sh("rm -rf #{host.dir}")
    end
  end
  
  # run the drb server stop command on the host machine
  # @param [HostMachine] host the host machine
  def stop_drb_server(host)
    host.sh("cd #{host.dir};ruby #{host.controller} stop")
  end
  
  # run the drb server start command on the host machine
  # @param [HostMachine] host the host machine
  def run_drb_server(host)
    unless host.controller.blank?
      host.sh("cd #{host.dir};ruby #{host.controller} start -- #{host.machine} #{host.port}")
    end
  end

  # Create the daemon controller on the host machine
  # @param [HostMachine] host the host machine
  def create_controller(host)
    unless @user_choices[:run].blank?
      host.controller = File.basename(@user_choices[:run], '.*') + '_controller.rb'
      controller = "require 'rubygems' ; require 'daemons' ; Daemons.run('#{@user_choices[:run]}')"
      host.sh("cd #{host.dir};echo \"#{controller}\" > #{host.controller}")
    end
  end
  
  # copy files from local directories to the created 
  # directory on the host machine
  # @param [HostMachine] host the host machine
  def upload_dirs(host)
    unless @user_choices[:dirs].blank?
      @user_choices[:dirs].each do |name|
        if File.directory?(name)
          host.upload(name, "#{host.dir}/#{File.basename(name)}")
        else
          @logger.error { "\"#{name}\" is not a directory" }
        end
      end
    end
  end
  
  # check if the required gems are installed on the host
  # @param [HostMachine] host the host machine
  def check_gems(host)
    unless @user_choices[:gems].blank?
      @user_choices[:gems].each do |gem_name|
        # str = host.sh("env")
        # @logger.debug { "=> #{str}"}
        str = host.sh("gem list -l -i #{gem_name}")
        # @logger.debug { "=> #{str.inspect}"}
        if str =~ /false/i
          @logger.info { "The \"#{gem_name}\" gem is not installed on #{host.name}" }
        end
      end
    end
  end

  # Create the directory that will hold the drb files.
  # The directory created is ~/.drbman/{uuid}
  # Note, requires 'uuidgen' in the path on the host machine
  # @todo maybe generate a random uuid locally instead
  # @param [HostMachine] host the host machine
  def create_directory(host)
    host.uuid = host.sh('uuidgen').strip
    host.dir = "~/.drbman/#{host.uuid}".strip
    host.sh("mkdir -p #{host.dir}")
    @logger.debug { "host directory: #{host.dir}" }
  end
  
end

