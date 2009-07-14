# Command design pattern
class SieveOfEratosthenes
  attr_reader :primes_elapse_time
  def initialize(n, choices, logger)
    @n = n.to_i
    @choices = choices
    @logger = logger
    
    # we need at least one host that has a drb server running
    @choices[:hosts] = ['localhost'] if @choices[:hosts].blank?
    
    # set the file to be ran that contains the drb server
    @choices[:run] = 'drb_server/prime_helper.rb' if @choices[:run].blank?
    @choices[:gems] = ['log4r']
    
    # specify the directories to copy to the host machine
    @choices[:dirs] = [File.join(File.dirname(__FILE__), '../drb_server')]
  end
  
  def execute
    result = []
    Drbman.new(@logger, @choices) do |drbman|
      @primes_elapse_time = elapse do
        result = primes(@n, drbman)
      end
    end
    result
  end
  
  private
  
  def primes(n, drbman)
    indices = []
    if n > 2
      composites = calc_composites(n, drbman)
      flat_comps = composites.flatten.uniq
      indices = calc_indices(flat_comps, n)
    end
    indices
  end

  # when n = 20
  # sqr_primes = [2,3]
  # composites = [[2*2, 2*3, 2*4,...,2*9], [3*2, 3*3, 3*4,...,3*6]]
  # returns Array
  def calc_composites(n, drbman)
    sqr_primes = primes(Math.sqrt(n).to_i, drbman)
    composites = []
    threads = []
    mutex = Mutex.new
    sqr_primes.each do |ip|
      # parallelize via threads
      # then use the drb object within the thread
      threads << Thread.new(ip, n) do |value, max|
        # @logger.debug { "thread(#{ip}, #{n})" }
        drbman.get_object do |prime_helper|
          # @logger.debug { "prime_helper.name => #{prime_helper.name}" }
          non_primes = prime_helper.non_primes(value, max)
          mutex.synchronize do
            composites << non_primes
          end
        end
      end
    end
    threads.each {|thrd| thrd.join}
    composites
  end
  
  def calc_indices(flat_comps, n)
    indices = []
    flags = Array.new(n, true)
    flat_comps.each {|i| flags[i] = false}
    flags.each_index {|i| indices << i if flags[i] }
    indices.shift(2)
    indices
  end
  
end
