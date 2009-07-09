$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'extlib'
require 'ruby-debug'
require 'versionomy'
require 'log4r'
require 'fileutils'
require 'user-choices'
require 'net/ssh'
require 'net/scp'

include FileUtils::Verbose

Dir.glob(File.join(File.dirname(__FILE__), 'drbman/**/*.rb')).each do |name| 
  require name
end

