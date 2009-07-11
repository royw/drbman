class CLI < UserChoices::Command
  include UserChoices
  include Singleton
  
  def self.execute
    instance.execute
  end
  
  def execute
    if @user_choices[:version]
      puts IO.read(File.join(File.dirname(__FILE__), '../../VERSION')).strip
    else
      logger = setup_logger
      begin
        # @user_choices[:hosts] << @user_choices[:host] unless @user_choices[:host].blank?
        raise Exception.new('Missing maximum integer argument') if @user_choices[:max_integer].nil?
        elapse_time = elapse do
          app = Primes.new(logger, @user_choices)
          primes = app.execute
          logger.info { "#{primes.length} primes found" }
        end
        puts "elapsed time: #{elapse_time}"
      rescue Exception => e
        logger.error { e.to_s }
        logger.error { e.backtrace.join("\n") }
      end
    end
  end
  
  def elapse(&block)
    seconds = 0
    unless block.nil?
      start_time = Time.now
      block.call
      seconds = Time.now - start_time
    end
    seconds
  end

  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage, "Usage #{$0} [options] INTEGER\nwhere INTEGER is the number to find all of the primes below.")
    builder.add_source(EnvironmentSource, :with_prefix, "primes_")
    builder.add_source(YamlConfigFileSource, :from_file, ".primes-config.yaml")
  end

  def add_choices(builder)
    # don't need to explicitly declare help argument
    builder.add_choice(:version, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-V', '--version', 'The version of primes')
    end
    builder.add_choice(:quiet, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-q', '--quiet', 'Display error messages only')
    end
    builder.add_choice(:debug, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-v', '--verbose', 'Display debug messages')
    end
    builder.add_choice(:hosts, :type => [:string], :default => []) do |command_line|
      command_line.uses_option('-H', '--hosts "HOST,HOST"', 'Comma separated host machines, ex: "machine1{,machine2{,...}}"')
    end
    builder.add_choice(:port, :type => :integer, :default => 9000) do |command_line|
      command_line.uses_option('-p', '--port PORT', "The starting port number to assign to the hosts.")
    end
    builder.add_choice(:max_integer) do |command_line|
      command_line.uses_optional_arg
    end
  end

  # == Synopsis
  # Initial setup of logger
  def setup_logger
    logger = Log4r::Logger.new('primes')
    logger.outputters = Log4r::StdoutOutputter.new(:console)
    Log4r::Outputter[:console].formatter  = Log4r::PatternFormatter.new(:pattern => "%m")
    logger.level = Log4r::DEBUG
    logger.level = Log4r::INFO
    logger.level = Log4r::WARN if @user_choices[:quiet]
    logger.level = Log4r::DEBUG if @user_choices[:debug]
    # logger.trace = true
    logger
  end
end
