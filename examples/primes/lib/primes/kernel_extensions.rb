module Kernel
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

