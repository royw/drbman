
class Primes 
  
  def initialize(logger, choices)
    @logger = logger
    @user_choices = choices
  end
  
  def execute
    @logger.debug { @user_choices.pretty_inspect }
    sieve = SieveOfEratosthenes.new(@user_choices[:max_integer], @user_choices, @logger)
    sieve.execute
  end
  
end