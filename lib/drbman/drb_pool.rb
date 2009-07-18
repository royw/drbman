# == Synopsis
# A pool of drb objects
class DrbPool
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

    threads = []
    mutex = Mutex.new
    @logger.debug { "drb_pool hosts => #{hosts.inspect}"}
    hosts.each do |host_name, host_machine|
      threads << Thread.new(host_machine) do |host|
        if host.alive?
          obj = get_drb_object(host.machine, host.port)
          unless obj.nil?
            mutex.synchronize do
              @objects << obj
            end
          end
        end
      end
    end
    threads.each {|thrd| thrd.join}

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
    raise EmptyDrbPoolError.new("No drb servers available") if @objects.empty?
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
      @objects.select {|obj| !obj.in_use?}.each do |obj|
        unless obj.nil?
          begin
            obj.name # make sure we can still talk with drb server
            obj.in_use = true 
            object = obj
            break
          rescue
            object = nil
          end
        end
      end
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
      obj.in_use = false
    rescue Exception => e
      retry_cnt += 1
      raise e if retry_cnt > 10
      sleep 0.2
      @logger.debug {"retrying (#{retry_cnt})"}
      retry
    end
    obj
  end
  
  # Adds an in_use attribute
  module InUse
    # set the in_use flag
    # @param [Boolean] flag
    # @return [Boolean] the new state of the in_use flag
    def in_use=(flag)
      @in_use = (flag ? true : false)
    end
    
    # get the in_use flag
    # @return [Boolean] the state of the in_use flag
    def in_use?
      @in_use
    end
  end
  
end
