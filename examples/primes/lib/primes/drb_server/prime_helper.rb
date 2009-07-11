require 'drb'

class PrimeHelper
  def non_primes(ip, n)
    a = []
    2.upto((n - 1) / ip) { |i| a << (i * ip) }
    a
  end
  def stop_service
    DRb.stop_service
  end
end

if __FILE__ == $0
  port = 9000
  port = ARGV[0] unless ARGV.empty?
  server = PrimeHelper.new
  DRb.start_service("druby://localhost:#{port}", server)
  DRb.thread.join
end
