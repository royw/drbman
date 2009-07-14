# == Synopsis
# A pool of drb objects
class DrbPool
  # @todo change to threaded
  THREADED = false
  
  # Create the pool of drb objects.
  # @param [Array<HostMachine>] the host_machine instances to use to populate the pool of drb objects
  # @param [Logger] the logger
  # @yield [self]
  # @example Without using a block
  #   pool = DrbPool.new(hosts, logger)
  #   pool.getObject {|obj| obj.do_something}
  #   pool.shutdown
  # @example Using a block
  #  DrbPool.new(hosts, logger) do |pool|
  #    pool.getObject {|obj| obj.do_something}
  #  end
  def initialize(hosts, logger, &block)
    @logger = logger
    @objects = []
    sleep 1
    if THREADED
      threads = []
      mutex = Mutex.new
      hosts.each do |host_name, host_machine|
        threads << Thread.new(host_machine) do |host|
          obj = get_drb_object(host.machine, host.port)
          mutex.synchronize do
            @objects << obj
          end
        end
      end
      threads.each {|thrd| thrd.join}
    else
      hosts.each do |host_name, host|
        obj = get_drb_object(host.machine, host.port)
        @objects << obj
      end
    end
    unless block.nil?
      block.call(self)
      shutdown
    end
  end
  
  # Use an object from the pool
  # @yield [DRbObject]
  # @example Usage
  #   pool.get_object {|obj| obj.do_something}
  def get_object(&block)
    mutex = Mutex.new
    while((object = next_object(mutex)).nil?)
      sleep 0.1 
    end
    raise ArgumentError.new('a block is required') if block.nil?
    block.call(object)
    object.in_use = false
  end
  
  # Shut the pool down
  # Only necessary if not using a block with DrbPool.new
  # @example
  #   pool = DrbPool.new(hosts, logger)
  #   pool.getObject {|obj| obj.do_something}
  #   pool.shutdown
  def shutdown
    @objects.each do |obj|
      obj.stop_service
    end
  end
  
  private

  # find the next available object
  # @return [DRbObject, nil] returns nil if no objects are available
  def next_object(mutex)
    object = nil
    mutex.synchronize do
      object = @objects.select {|obj| !obj.in_use?}.first
      object.in_use = true unless object.nil?
    end
    object
  end
  
  # Get a DRbObject to place into the pool
  # The object is extended with an in_use attribute
  # @param machine [String] the host machine name, for example: 'foo.example.com'
  # @param port [Integer] the port the drb server on the host machine is using
  # @return [DRbObject,nil] returns nil if unable to get the DRbObject
  def get_drb_object(machine, port)
    obj = nil
    retry_cnt = 0
    DRb.start_service
    begin
      obj = DRbObject.new(nil, "druby://#{machine}:#{port}")
      obj.extend(InUse)
      name = obj.name
      # @logger.debug {"DrbObject.name => #{name}"}
      obj.in_use = false
    rescue Exception => e
      retry_cnt += 1
      raise e if retry_cnt > 10
      sleep 0.5
      @logger.debug {"retrying (#{retry_cnt})"}
      retry
    end
    obj
  end
  
  # Adds an in_use attribute
  module InUse
    def in_use=(flag)
      @in_use = (flag ? true : false)
    end
    def in_use?
      @in_use
    end
  end
  
end
