require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'primes'


describe('SieveOfEratosthenes') do
  before(:each) do
    @choices = {}
    @logger = Log4r::Logger.new('primes_spec')
    @logger.level = Log4r::DEBUG
  end
  
  it 'should find [2,3,5,7,11,13,17,19] for n=20' do
    @choices[:max_integer] = 20
    sieve = Primes.new(@logger, @choices)
    sieve.execute.should == [2,3,5,7,11,13,17,19]
  end
  it 'should take a while' do
    sieve = SieveOfEratosthenes.new(10000000, @choices, @logger)
    primes = sieve.execute
    puts "#{primes.length} primes found"
    primes.length.should == 664579
  end
end

