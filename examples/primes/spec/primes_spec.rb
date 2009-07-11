$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'spec'
require 'sieve_of_eratosthenes'


describe('SieveOfEratosthenes') do
  it 'should find [2,3,5,7,11,13,17,19] for n=20' do
    sieve = SieveOfEratosthenes.new(20)
    sieve.execute.should == [2,3,5,7,11,13,17,19]
  end
  it 'should take a while' do
    sieve = SieveOfEratosthenes.new(10000000)
    primes = sieve.execute
    puts "#{primes.length} primes found"
    primes.length.should == 664579
  end
end

# 1111 1111 1111 1111 0000