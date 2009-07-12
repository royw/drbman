class DrbPool
  def initialize(choices, &block)
    port = choices[:port] || 9000
    hosts = choices[:hosts] || ['localhost']
    raise ArgumentError if choices[:run].blank?
    @objects = []
    puts "hosts: #{hosts.inspect}"
    # hosts.each do |host|
    #   run_prime_helper = "ruby #{File.join(File.dirname(__FILE__), choices[:run])} #{port}"
    #   start_drb(run_prime_helper)
    #   port += 1
    # end
    sleep 1
    hosts.each do |host|
      @objects << get_drb_object(host, port)
      port += 1
    end
    unless block.nil?
      block.call(self)
      shutdown
    end
  end
  
  def get_object(&block)
    mutex = Mutex.new
    while((object = next_object(mutex)).nil?)
      sleep 0.1 
    end
    raise ArgumentError.new('a block is required') if block.nil?
    block.call(object)
    object.in_use = false
  end
  
  def shutdown
    @objects.each do |obj|
      obj.stop_service
    end
  end
  
  private

  def next_object(mutex)
    object = nil
    mutex.synchronize do
      object = @objects.select {|obj| !obj.in_use?}.first
      object.in_use = true unless object.nil?
    end
    object
  end
  
  # def start_drb(commandline)
  #   exec(commandline) if fork.nil?
  # end
  
  def get_drb_object(machine, port)
    obj = nil
    retry_cnt = 0
    DRb.start_service
    begin
      obj = DRbObject.new(nil, "druby://#{machine}:#{port}")
      obj.extend(InUse)
      obj.in_use = false
    rescue Exception => e
      retry_cnt += 1
      raise e if retry_cnt > 10
      sleep 0.1
      retry
    end
    obj
  end
  
  module InUse
    def in_use=(flag)
      @in_use = (flag ? true : false)
    end
    def in_use?
      @in_use
    end
  end
  
end
