# The Sieve of Eratosthenes prime number finder
# Note, uses the Command design pattern
class SieveOfEratosthenes
  attr_reader :primes_elapse_time

  # Use the Sieve of Eratosthenes to find prime numbers
  #
  # @param [Integer] maximum find all primes lower than this maximum value - REQUIRED.
  # @option choices [Hash<String,String>] :dirs hash of local directories to copy to the host 
  #   machines where key is local source and value is directory on host machine - REQUIRED.
  # @option choices [String] :run the name of the file to run on the host machine - REQUIRED.
  #  This file should start the drb server.  Note, this file will be daemonized before running.
  # @option choices [Array<String>] :hosts (['localhost']) array of host machine descriptions "{user{:password}@}machine{:port}".
  # @option choices [Integer] :port (9000) default port number used to assign to hosts without a port number,
  #  the port number is incremented for each host.
  # @option choices [Array<String>] :gems array of gem names to verify are installed on the host machine.
  #  Note, 'daemons' is always added to this array.
  # @param [Logger] logger the logger to use
  def initialize(maximum, choices, logger)
    @maximum = maximum.to_i
    @choices = choices
    @logger = logger
    
    # we need at least one host that has a drb server running
    @choices[:hosts] = ['localhost'] if @choices[:hosts].blank?
    
    # specify the directories to copy to the host machine
    @choices[:dirs] = {File.join(File.dirname(__FILE__), '../drb_server') => 'drb_server'}

    # set the file to be ran that contains the drb server
    @choices[:run] = 'drb_server/prime_helper.rb' if @choices[:run].blank?
    
    # specify gems required by the drb server object
    # each host will be checked to make sure these gems are installed
    @choices[:gems] = ['log4r']
    
  end
  
  # Calculate the primes
  # @return [Array<Integer] the primes in an Array
  def execute
    result = []
    @logger.debug { @choices.pretty_inspect }

    Drbman.new(@logger, @choices) do |drbman|
      @primes_elapse_time = elapse do
        result = primes(@maximum, drbman)
      end
    end
    result
  end
  
  private
  
  # recursive prime calculation
  # @param maximum (see #initialize)
  # @param [Drbman] drbman the drb manager instance
  # @return [Array<Integer>] the array of primes
  def primes(maximum, drbman)
    indices = []
    if maximum > 2
      composites = calc_composites(maximum, drbman)
      flat_comps = composites.flatten.uniq
      indices = calc_indices(flat_comps, maximum)
    end
    indices
  end

  # find the composites array
  # @param maximum (see #initialize)
  # @param drbman (see #primes)
  # @return [Array<Integer>] the composites array
  def calc_composites(maximum, drbman)
    # when n = 20
    # sqr_primes = [2,3]
    # composites = [[2*2, 2*3, 2*4,...,2*9], [3*2, 3*3, 3*4,...,3*6]]
    sqr_primes = primes(Math.sqrt(maximum).to_i, drbman)
    composites = []
    threads = []
    mutex = Mutex.new
    sqr_primes.each do |ip|
      # parallelize via threads
      # then use the drb object within the thread
      threads << Thread.new(ip, maximum) do |prime, max|
        drbman.get_object do |prime_helper|
          prime_multiples = prime_helper.multiples_of(prime, max)
          mutex.synchronize do
            composites << prime_multiples
          end
        end
      end
    end
    threads.each {|thrd| thrd.join}
    composites
  end
  
  # sift the indices to find the primes
  # @param [Array<Integer>] flat_comps the flattened composites array
  # @param maximum (see #initialize)
  def calc_indices(flat_comps, maximum)
    indices = []
    flags = Array.new(maximum, true)
    flat_comps.each {|i| flags[i] = false}
    flags.each_index {|i| indices << i if flags[i] }
    indices.shift(2)
    indices
  end
  
end
