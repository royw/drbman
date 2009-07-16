# == Synopsis
# Calculate the prime numbers less than a given maximum integer.
#
#  @example
#    choices = {}
#    choices[:max_integer] = 20
#    sieve = Primes.new(@logger, choices)
#    primes = sieve.execute
#    # primes => [2,3,5,7,11,13,17,19]
#
# Note, uses the Command design pattern
class Primes 
  attr_reader :primes_elapse_time

  # @param [Logger] logger the logger to use
  # @param choices {see SieveOfEratosthenes#Initialize}
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