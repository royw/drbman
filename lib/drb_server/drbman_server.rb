require 'drb'

module DrbmanServer
  attr_accessor :name
  # Stop the DRb service
  def stop_service
    DRb.stop_service
  end
  
  def start_service(klass)
    machine = 'localhost'
    machine = ARGV[0] unless ARGV.length < 1
    port = 9000
    port = ARGV[1] unless ARGV.length < 2
    server = klass.new
    server.name = "druby://#{machine}:#{port}"
    # puts server.inspect
    DRb.start_service(server.name, server)
    DRb.thread.join
  end
  module_function :start_service
end
