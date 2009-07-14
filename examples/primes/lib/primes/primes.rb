
class Primes 
  attr_reader :primes_elapse_time
  
  def initialize(logger, choices)
    @logger = logger
    @user_choices = choices
  end
  
  def execute
    @logger.debug { @user_choices.pretty_inspect }
    sieve = SieveOfEratosthenes.new(@user_choices[:max_integer], @user_choices, @logger)
    result = sieve.execute
    @primes_elapse_time = sieve.primes_elapse_time
    result
  end
  

end