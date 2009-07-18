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
  
  it 'should find 303 primes below 2000 for password host' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}:#{ENV['TEST_PASSWORD']}@#{ENV['TEST_HOST']}"]
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end
  
  it 'should robustly fail for invalid password' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}:badpassword@#{ENV['TEST_HOST']}"]
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 0
  end
  
  it 'should robustly fail for missing password' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}@#{ENV['TEST_HOST']}"]
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 0
  end
  
  it 'should find 303 primes below 2000 for password host and localhost' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}:#{ENV['TEST_PASSWORD']}@#{ENV['TEST_HOST']}", 'localhost']
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end
  
  it 'should find 303 primes below 2000 for invalid password host and localhost' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}:badpassword@#{ENV['TEST_HOST']}", 'localhost']
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end
  
  it 'should find 303 primes below 2000 for missing password host and localhost' do
    env_ok.should be_true
    @choices[:max_integer] = 2000
    @choices[:hosts] = ["#{ENV['TEST_USER']}@#{ENV['TEST_HOST']}", 'localhost']
    sieve = Primes.new(@logger, @choices)
    sieve.execute.length.should == 303
  end
  
end

def env_ok
  result = !(ENV['TEST_HOST'].nil? || ENV['TEST_USER'].nil? || ENV['TEST_PASSWORD'].nil?)
  unless result
    puts
    puts "You need to setup the following environment variables: TEST_HOST, TEST_USER, TEST_PASSWORD"
    puts "Alternatively run spec like:  TEST_HOST='box' TEST_USER='who' TEST_PASSWORD='sekret' spec spec/primes_spec.rb"
    puts
  end
  result
end
