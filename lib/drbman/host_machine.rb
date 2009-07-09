# HostMachine is used to interface with a host machine
# == Synopsis
# == Usage
# == Notes
# A host machine may be either another machine or the localhost.
# By supporting localhost, it is likely that the process will
# be on a different core than the current processes.
#
# Once HostMachine opens an ssh connection, it does not close
# the connection until a disconnect() is invoked.
class HostMachine
  attr_accessor :uuid, :dir
  attr_reader :name, :host, :user
  
  def initialize(host_string, logger)
    @name = host_string
    @logger = logger
    @host = 'localhost'
    @user = ENV['USER']
    @password = {:keys => ['~/.ssh/id_dsa']}
    case host_string
    when /^(\S+)\:(\S+)\@(\S+)$/
      @user = $1
      @password = {:password => $2}
      @host = $3
    when /^(\S+)\@(\S+)$/
      @user = $1
      @host = $2
    when /^(\S+)$/
      @host = $1
    end
    @ssh = nil
  end
  
  def session(&block)
    connect
    yield self
    disconnect
  end
  
  def upload(local_src, remote_dest)
    @logger.debug { "upload(\"#{local_src}\", \"#{remote_dest}\")" }
    connect
    result = nil
    unless @ssh.nil?
      begin
        @ssh.scp.upload!(local_src, remote_dest, :recursive => true) do |ch, name, sent, total|
          @logger.debug { "#{name}: #{sent}/#{total}" }
        end
        @ssh.loop
      rescue Exception => e
        # only raise the exception if the files differ
        raise e unless same_files?(local_src, remote_dest)
      end
    end
  end
  
  def download(remote_src, local_dest)
    connect
    result = nil
    unless @ssh.nil?
      @ssh.scp.download!(local_src, remote_dest)
    end
  end
  
  def sh(command)
    @logger.debug { "sh \"#{command}\""}
    connect
    result = nil
    unless @ssh.nil?
      result = @ssh.exec!("source ~/.profile && #{command}")
      # buf = []
      # @ssh.open_channel do |channel|
      #   channel.request_pty do |ch, success|
      #     # @logger.debug { "request_pty => #{success.inspect}" }
      #   end
      #   channel.exec("source ~/.profile && #{command}") do |ch, success|
      #     ch.on_data do |ch, data|
      #       # puts data
      #       buf << data
      #     end
      #   end
      # end
      # @ssh.loop
      # # p ['buf', buf]
      # result = buf.compact.join('')
    end
    result
  end
  
  def sudo(command)
    @logger.debug { "sudo \"#{command}\""}
    connect
    result = nil
    unless @ssh.nil?
      buf = []
      @ssh.open_channel do |channel|
        channel.exec("source ~/.profile && sudo -p 'sudo password: ' #{command}") do |ch, success|
          ch.on_data do |ch, data|
            if data =~ /sudo password: /
              ch.send_data("#{@password[:password]}\n")
            else
              buf << data
            end
          end
        end
      end
      @ssh.loop
      result = buf.compact.join('')
    end
    result
  end
  
  def connect
    @ssh ||= Net::SSH.start(@host, @user, @password)
  end
  
  def disconnect
    if @ssh
      @ssh.close
      @ssh = nil
    end
  end

  private
  
  def same_files?(local_path, remote_path)
    md5 = {}
    @ssh.exec!(md5_command_line(remote_path)).split("\n").each do |line|
      sum, filename = line.split(' ')
      md5[filename] = sum
    end
    `#{md5_command_line(local_path)}`.split("\n").each do |line|
      sum, filename = line.split(' ')
      if md5[filename].nil?
        md5[filename] = sum
      else
        if md5[filename] == sum
          md5.delete(filename) 
        end
      end
    end
    md5.empty?
  end
  
  def md5_command_line(dirname)
    line = "find #{dirname} -type f -exec ruby -e \"require 'digest/md5';puts Digest::MD5.hexdigest(open('{}').read)+' '+\"'{}'\"\" \;"
    @logger.debug { line }
    line
  end
  
end
