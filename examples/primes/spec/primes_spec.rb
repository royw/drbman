require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'primes'

# Note, these assume you have an ssh public key set up for
# this box (i.e: it does an "ssh localhost").

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
  
  it 'should find 303 primes below 2000 with single host' do
    @choices[:max_integer] = 2000
    @choices[:hosts] = ['localhost']
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end

  it 'should find 303 primes below 2000 with two hosts' do
    @choices[:max_integer] = 2000
    @choices[:hosts] = ['localhost', 'localhost']
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end
  
end

