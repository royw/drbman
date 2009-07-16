module Kernel
  # adds a elapse time method
  # @yield the block to find the execution elapsed time of
  # @return [Float] the number of seconds the block took to execute
  def elapse(&block)
    seconds = 0
    unless block.nil?
      start_time = Time.now
      block.call
      seconds = Time.now - start_time
    end
    seconds
  end
end

