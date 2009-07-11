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
# == Usage
# app = Drbman.new(logger, choices)
# app.execute
#
# where
# logger is a standard logger like log4r
# choice behaves like a hash (ex: a UserChoices instance)
#
# The supported choices are:
# :hosts => Array of Strings ['{user{:password}@}machine',...]
# :files => String local path to files to copy to host machine
# :gems => Array of Strings containing gem names ['gem_name',...]
# :run => String command line to run to start drb server on host machine
# :terminate => String command line to run to stop drb server on host machine
# :cleanup => Boolean if true, then remove the directory used on the host machine
#
# == Notes
# Uses the Command design pattern
class Drbman
  def initialize(logger, choices, &block)
    @logger = logger
    @user_choices = choices
    @hosts = {}

    @logger.debug { @user_choices.pretty_inspect }
    @user_choices[:hosts].each do |host|
      @hosts[host] = HostMachine.new(host, @logger)
    end
    
    unless block.nil?
      setup
      block.call(self)
      @pool.shutdown unless @pool.nil
      shutdown
    end
  end
  
  def get_object(&block)
    @pool ||= DrbPool.new(@user_choices)
    @pool.get_object(block)
  end
  
  def setup
    @user_choices[:cleanup] = false
    execute
  end
  
  def shutdown
    @user_choices[:cleanup] = true
    execute
  end
  
  def execute
    @hosts.each do |name, host_machine|
      host_machine.session do |host|
        unless @user_choices[:cleanup]
          @logger.info { "Setting up: #{host.name}" }
          check_gems(host)
          create_directory(host)
          upload_dirs(host)
          run_drb_server(host)
        else
          @logger.info { "Cleaning up: #{host.name}" }
          stop_drb_server(host)
          cleanup_files(host)
        end
        @logger.info { '' }
      end
    end
  end
  
  private
  
  # remove the host directory and any files in it from
  # the host machine
  def cleanup_files(host)
    if @user_choices[:cleanup]
      unless host.dir.blank? || (host.dir =~ /[\*\?]/)
        @logger.info { "#{host.name}: rm -rf #{host.dir}"}
        host.sh("rm -rf #{host.dir}")
      end
    end
  end
  
  # run the drb server stop command on the host machine
  def stop_drb_server(host)
    unless @user_choices[:stop].blank?
      host.sh(@user_choices[:stop])
    end
  end
  
  # run the drb server start command on the host machine
  def run_drb_server(host)
    unless @user_choices[:run].blank?
      host.sh(@user_choices[:run])
    end
  end
  
  # copy files from local directories to the created 
  # directory on the host machine
  def upload_dirs(host)
    unless @user_choices[:dirs].blank?
      @user_choices[:dirs].each do |name|
        if File.directory?(name)
          host.upload(name, "#{host.dir}/#{name}")
        else
          @logger.error { "\"#{name}\" is not a directory" }
        end
      end
    end
  end
  
  # check if the required gems are installed on the host
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

  def create_directory(host)
    host.uuid = host.sh('uuidgen').strip
    host.dir = ".drbman/#{host.uuid}".strip
    host.sh("mkdir -p #{host.dir}")
    @logger.info { "host directory: #{host.dir}" }
  end
  
end

