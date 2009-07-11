# Command design pattern
class SieveOfEratosthenes
  def initialize(n)
    @n = n.to_i
    @hosts = ['localhost']
    @starting_port = 9000
  end
  
  def drb_hosts(hosts, starting_port)
    @hosts = hosts
    @starting_port = starting_port
    @hosts = ['localhost', 'localhost'] if @hosts.blank?
    @starting_port = 9000 if @starting_port.blank?
  end
  
  def execute
    result = []
    DrbPool.new(@hosts, @starting_port) do |pool|
      result = primes(@n, pool)
    end
    result
  end
  
  private
  
  def primes(n, drb_pool)
    indices = []
    if n > 2
      composites = calc_composites(n, drb_pool)
      flat_comps = composites.flatten.uniq
      indices = calc_indices(flat_comps, n)
    end
    indices
  end

  # returns Array with length < n
  def calc_composites(n, drb_pool)
    sqr_primes = primes(Math.sqrt(n).to_i, drb_pool)
    composites = []
    threads = []
    mutex = Mutex.new
    sqr_primes.each do |ip|
      # when n = 20
      # sqr_primes = [2,3]
      # composites = [[2*2, 2*3, 2*4,...,2*9], [3*2, 3*3, 3*4,...,3*6]]
      threads << Thread.new(ip, n) do |value, max|
        drb_pool.get_object do |prime_helper|
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
