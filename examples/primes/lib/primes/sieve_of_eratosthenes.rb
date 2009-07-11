# Command design pattern
class SieveOfEratosthenes
  def initialize(n, choices, logger)
    @n = n.to_i
    @choices = choices
    @logger = logger
    @choices[:run] = 'drb_server/prime_helper.rb' if @choices[:run].blank?
    @choices[:files] = [File.join(File.dirname(__FILE__), 'drb_server')]
  end
  
  def execute
    result = []
    # DrbPool.new(@choices) do |pool|
    Drbman.new(@logger, @choices) do |drbman|
      result = primes(@n, drbman)
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

  # returns Array
  def calc_composites(n, drbman)
    sqr_primes = primes(Math.sqrt(n).to_i, drbman)
    composites = []
    threads = []
    mutex = Mutex.new
    sqr_primes.each do |ip|
      # when n = 20
      # sqr_primes = [2,3]
      # composites = [[2*2, 2*3, 2*4,...,2*9], [3*2, 3*3, 3*4,...,3*6]]
      threads << Thread.new(ip, n) do |value, max|
        drbman.get_object do |prime_helper|
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
