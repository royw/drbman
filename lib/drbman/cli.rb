# require 'commandline/optionparser'

# == Synopsis
# The Command Line Interface
class CLI < UserChoices::Command
  include UserChoices
  include Singleton
  
  # The CLI class uses the command design pattern.
  # This is a class accessor helper
  # @example
  #   CLI.execute
  def self.execute
    instance.execute
  end
  
  # The CLI class uses the command design pattern
  # This is the main entry point
  def execute
    if @user_choices[:version]
      puts IO.read(File.join(File.dirname(__FILE__), '../../VERSION')).strip
    else
      logger = setup_logger
      begin
        app = Drbman.new(logger, @user_choices)
        app.execute
      rescue Exception => e
        logger.error { e.to_s }
        logger.error { e.backtrace.join("\n") }
      end
    end
  end
  
  protected
  
  # @param builder (see UserChoices::Command#add_sources)
  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage, "Usage #{$0} [options]")
    builder.add_source(EnvironmentSource, :with_prefix, "drbman_")
    builder.add_source(YamlConfigFileSource, :from_file, ".drbman-config.yaml")
  end
  
  # @param builder (see UserChoices::Command#add_choices)
  def add_choices(builder)
    # don't need to explicitly declare help argument
    builder.add_choice(:version, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-V', '--version', 'The version of drbman')
    end
    builder.add_choice(:quiet, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-q', '--quiet', 'Display error messages only')
    end
    builder.add_choice(:debug, :type => :boolean, :default => false) do |command_line|
      command_line.uses_switch('-v', '--verbose', 'Display debug messages')
    end
    builder.add_choice(:run, :type => :string, :default => nil) do |command_line|
      command_line.uses_option('-r', '--run "COMMAND"', "The ruby file that starts the drb server")
    end
    builder.add_choice(:hosts, :type => [:string], :default => []) do |command_line|
      command_line.uses_option('-H', '--hosts "HOST,HOST"', 'Comma separated account URLs, ex: "{user{:pass}@}machine1{,{user{:pass}@}machine2}"')
    end
    builder.add_choice(:dirs, :type => [:string], :default => []) do |command_line|
      command_line.uses_option('-d', '--dirs "PATH,PATH"', "Comma separated paths to directories to copy to the host machine(s)")
    end
    builder.add_choice(:gems, :type => [:string], :default => []) do |command_line|
      command_line.uses_option('-g', '--gems "GEM,GEM"', "Comma separated list of gems that have to be installed on the host machine")
    end
  end
  
  # Initial setup of logger
  # @return [Logger] the logger to use
  def setup_logger
    logger = Log4r::Logger.new('drbman')
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


