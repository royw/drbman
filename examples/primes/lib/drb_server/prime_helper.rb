require 'drb'
require 'log4r'

class PrimeHelper
  attr_accessor :name
  def non_primes(ip, n)
    a = []
    2.upto((n - 1) / ip) { |i| a << (i * ip) }
    a
  end
  def stop_service
    DRb.stop_service
  end
end

logger = Log4r::Logger.new('prime_helper')
logger.outputters = Log4r::FileOutputter.new(:console, :filename => File.join(File.dirname(__FILE__), '../prime_helper.log'))
Log4r::Outputter[:console].formatter  = Log4r::PatternFormatter.new(:pattern => "%m")
logger.level = Log4r::INFO

machine = 'localhost'
machine = ARGV[0] unless ARGV.length < 1
port = 9000
port = ARGV[1] unless ARGV.length < 2
service = "druby://#{machine}:#{port}"
logger.info { "ARGV => #{ARGV.inspect}" }
logger.info { "machine => #{machine}" }
logger.info { "port => #{port}" }
logger.info { "drb service => #{service}" }
server = PrimeHelper.new
server.name = service
DRb.start_service(service, server)
DRb.thread.join
logger.info { "finished" }
