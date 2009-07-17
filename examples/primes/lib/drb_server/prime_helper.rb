require 'drbman_server'

# A helper object for calculating primes using the Sieve of Eratosthenes
#
# == Usage
# ruby prime_helper.rb foo.example.com 1234
# will run the service as: druby://foo.example.com:1234
#
# ruby prime_helper.rb foo.example.com
# will run the service as: druby://foo.example.com:9000
#
# ruby prime_helper.rb
# will run the service as: druby://localhost:9000
#
class PrimeHelper
  include DrbmanServer
  
  # Find the multiples of the give prime number that are less than the 
  # given maximum.
  # @example
  #  multiples_of(5,20) => [10, 15]
  # @param [Integer] prime the prime number to find the multiples of
  # @param [Integer] maximum the maximum integer
  # @return [Array<Integer>] the array of the prime multiples
  def multiples_of(prime, maximum)
    a = []
    2.upto((maximum - 1) / prime) { |i| a << (i * prime) }
    a
  end
end

DrbmanServer.start_service(PrimeHelper)
