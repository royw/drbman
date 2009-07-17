$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

# gem 'ruby-debug',       '>=0.10.3'
gem 'log4r',            '>=1.0.5'
gem 'user-choices',     '>=1.1.6'
gem 'extlib',           '>=0.9.12'
gem 'net-ssh',          '>=2.0.11'
gem 'net-scp',          '>=1.0.2'
gem 'daemons',          '>=1.0.10'
gem 'uuidtools',        '>=2.0.0'

require 'extlib'
# require 'ruby-debug'
require 'log4r'
require 'user-choices'
require 'net/ssh'
require 'net/scp'
require 'daemons'
require 'uuidtools'
require 'tempfile'

# require all of the .rb files in the drbman/ subdirectory
Dir.glob(File.join(File.dirname(__FILE__), 'drbman/**/*.rb')).each do |name| 
  require name
end

