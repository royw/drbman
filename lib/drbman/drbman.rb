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
  # @option choices [Array<String>] :dirs array of local directories to copy to the host machines (REQUIRED).
  # @option choices [String] :run the name of the file to run on the host machine (REQUIRED).
  #  This file should start the drb server.  Note, this file will be daemonized before running.
  # @option choices [Array<String>] :hosts (['localhost']) array of host machine descriptions "{user{:password}@}machine{:port}".
  # @option choices [Integer] :port (9000) default port number used to assign to hosts without a port number,
  #  the port number is incremented for each host.
  # @option choices [Array<String>] :gems ([]) array of gem names to verify are installed on the host machine,
  #  note, 'daemons' is always added to this array.
  # @option choices [Array<String>] :keys (['~/.ssh/id_dsa', '~/.ssh/id_rsa']) array of ssh key file names.
  # @yield [Drbman]
  # @example Usage
  #   Drbman.new(logger, choices) do |drbman|
  #     drbman.get_object do |obj|
  #       obj.do_something
  #     end
  #   end
  def initialize(logger, choices, &block)
    @logger = logger
    @user_choices = choices
    
    # @hosts[machine_description] = HostMachine instance
    @hosts = {}

    @user_choices[:port] ||= 9000
    @user_choices[:hosts] ||= ['localhost']
    @user_choices[:gems] ||= []
    @user_choices[:gems] = (@user_choices[:gems] + ['daemons']).uniq.compact
    
    raise ArgumentError.new('Missing choices[:run]')   if @user_choices[:run].blank?
    raise ArgumentError.new('Missing choices[:hosts]') if @user_choices[:hosts].blank?
    raise ArgumentError.new('Missing choices[:dirs]')  if @user_choices[:dirs].blank?
    
    # populate the @hosts hash.  key => host machine description, value => HostMachine instance
    port = @user_choices[:port]
    @user_choices[:hosts].each do |host|
      host = "#{host}:#{port}" unless host =~ /\:\d+\s*$/
      @hosts[host] = HostMachine.new(host, @logger, @user_choices)
      port += 1
    end
    
    unless block.nil?
      begin
        setup
        @pool = DrbPool.new(@hosts, @logger)
        block.call(self)
      rescue Exception => e
        @logger.error { e }
        @logger.debug { e.backtrace.join("\n") }
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
  # @raise [Exception] when a component is not installed on the host
  def setup
    threads = []
    @hosts.each do |name, machine|
      threads << Thread.new(machine) do |host_machine|
        host_machine.session do |host|
          startup(host)
        end
      end
    end
    threads.each {|thrd| thrd.join}
    sleep 1  # give the drb servers a little time to get running
  end
  
  # stop and remove the host machine drb servers
  def shutdown
    threads = []
    @hosts.each do |name, machine|
      threads << Thread.new(machine) do |host_machine|
        host_machine.session do |host|
          begin
            cleanup(host)
          rescue Exception => e
            @logger.error { e }
            @logger.debug { e.backtrace.join("\n") }
          end
        end
      end
    end
    threads.each {|thrd| thrd.join}
  end
  
  # Setup the drb server on the given host then start it
  # @param [HostMachine] host the host machine
  # @raise [Exception] when a component is not installed on the host
  def startup(host)
    @logger.debug { "Setting up: #{host.name}" }
    check_gems(host)
    create_directory(host)
    upload_dirs(host)
    create_controller(host)
    run_drb_server(host)
  end
  
  # Stop the drb server on the given host then remove the drb files from the host
  # @param [HostMachine] host the host machine
  def cleanup(host)
    @logger.debug { "Cleaning up: #{host.name}" }
    stop_drb_server(host)
    cleanup_files(host)
  end
  
  # remove the host directory and any files in it from
  # the host machine
  # @param [HostMachine] host the host machine
  def cleanup_files(host)
    unless host.dir.blank? || (host.dir =~ /[\*\?]/)
      @logger.debug { "#{host.name}: rm -rf #{host.dir}"}
      host.sh("rm -rf #{host.dir}") unless @user_choices[:leave]
    end
  end
  
  # run the drb server stop command on the host machine
  # @param [HostMachine] host the host machine
  # @raise [Exception] when ruby is not installed on the host
  def stop_drb_server(host)
    case host.sh("cd #{host.dir};ruby #{host.controller} stop")
    when /command not found/
      raise Exception.new "Ruby is not installed on #{host.name}"
    end
  end
  
  # run the drb server start command on the host machine
  # @param [HostMachine] host the host machine
  # @raise [Exception] when ruby is not installed on the host
  def run_drb_server(host)
    unless host.controller.blank?
      case host.sh("cd #{host.dir};ruby #{host.controller} start -- #{host.machine} #{host.port}")
      when /command not found/
        raise Exception.new "Ruby is not installed on #{host.name}"
      end
    end
  end
  
  # Create the daemon controller on the host machine
  # @param [HostMachine] host the host machine
  def create_controller(host)
    unless @user_choices[:run].blank?
      host.controller = File.basename(@user_choices[:run], '.*') + '_controller.rb'
      tempfile = Tempfile.new('controller')
      tempfile.puts "require 'rubygems'"
      tempfile.puts "require 'daemons'"
      tempfile.puts "$LOAD_PATH.unshift(File.expand_path(File.dirname('#{@user_choices[:run]}')))"
      tempfile.puts "Daemons.run('#{@user_choices[:run]}')"
      tempfile.close
      host.upload(tempfile.path, host.dir)
      host.sh("cd #{host.dir};mv #{File.basename(tempfile.path)} #{host.controller}")
    end
  end
  
  # copy files from local directories to the created 
  # directory on the host machine
  # @param [HostMachine] host the host machine
  def upload_dirs(host)
    unless @user_choices[:dirs].blank?
      drb_server_file = File.join(File.dirname(__FILE__), "../drb_server/drbman_server.rb")
      @user_choices[:dirs].each do |name|
        if File.directory?(name)
          host.upload(name, "#{host.dir}/#{File.basename(name)}")
          host.upload(drb_server_file, "#{host.dir}/#{File.basename(name)}")
        else
          @logger.error { "\"#{name}\" is not a directory" }
        end
      end
    end
  end
  
  # check if the required gems are installed on the host
  # @param [HostMachine] host the host machine
  # @raise [Exception] when rubygems is not installed on the host
  def check_gems(host)
    missing_gems = []
    @user_choices[:gems].each do |gem_name|
      case str = host.sh("gem list -l -i #{gem_name}")
      when /false/i
        missing_gems << gem_name
      when /command not found/
        raise Exception.new "Rubygems is not installed on #{host.name}"
      end
    end
    unless missing_gems.empty?
      raise Exception.new "The following gems are not installed on #{host.name}: #{missing_gems.join(', ')}"
    end
  end

  # Create the directory that will hold the drb files.
  # The directory created is ~/.drbman/{uuid}
  # Note, requires 'uuidgen' in the path on the host machine
  # @todo maybe generate a random uuid locally instead
  # @param [HostMachine] host the host machine
  # @return [String] the created directory path
  def create_directory(host)
    host.uuid = UUIDTools::UUID.random_create
    host.dir = "~/.drbman/#{host.uuid}".strip
    host.sh("mkdir -p #{host.dir}")
    @logger.debug { "host directory: #{host.dir}" }
    host.dir
  end
  
end

