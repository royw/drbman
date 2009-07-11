
class Primes 
  
  def initialize(logger, choices)
    @logger = logger
    @user_choices = choices
  end
  
  def execute
    @logger.debug { @user_choices.pretty_inspect }
    sieve = SieveOfEratosthenes.new(@user_choices[:max_integer])
    sieve.drb_hosts(@user_choices[:hosts], @user_choices[:port])
    primes = sieve.execute
    @logger.info { "#{primes.length} primes found" }
    primes
  end
  
end