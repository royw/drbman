$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

gem 'ruby-debug',       '>=0.10.3'
gem 'log4r',            '>=1.0.5'
gem 'user-choices',     '>=1.1.6'
gem 'extlib',           '>=0.9.12'
gem 'versionomy',       '>=0.0.4'
gem 'net-ssh',          '>=2.0.11'
gem 'net-scp',          '>=1.0.2'
gem 'daemons',          '>=1.0.10'

require 'extlib'
require 'ruby-debug'
require 'versionomy'
require 'log4r'
require 'fileutils'
require 'user-choices'
require 'net/ssh'
require 'net/scp'
require 'daemons'

include FileUtils::Verbose

Dir.glob(File.join(File.dirname(__FILE__), 'drbman/**/*.rb')).each do |name| 
  require name
end

