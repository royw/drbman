require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe('HostMachine') do
  before(:each) do
    @logger = Log4r::Logger.new('host_machine_spec')
  end
  
  it "should parse: localhost" do
    host_machine = HostMachine.new('localhost', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'localhost'
    host_machine.port.should == 9000
  end

  it "should parse: localhost:1234" do
    host_machine = HostMachine.new('localhost:1234', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'localhost:1234'
    host_machine.port.should == 1234
  end
  it "should parse: me@localhost" do
    host_machine = HostMachine.new('me@localhost', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'me@localhost'
    host_machine.port.should == 9000
  end
  it "should parse: me@localhost:1234" do
    host_machine = HostMachine.new('me@localhost:1234', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'me@localhost:1234'
    host_machine.port.should == 1234
  end
  it "should parse: me:sekret@localhost" do
    host_machine = HostMachine.new('me:sekret@localhost', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'me:sekret@localhost'
    host_machine.port.should == 9000
  end
  it "should parse: me:sekret@localhost:1234" do
    host_machine = HostMachine.new('me:sekret@localhost:1234', @logger)
    host_machine.machine.should == 'localhost'
    host_machine.name.should == 'me:sekret@localhost:1234'
    host_machine.port.should == 1234
  end
end
