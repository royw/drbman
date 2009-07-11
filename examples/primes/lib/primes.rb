$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

# gem 'ruby-debug',       '0.10.3'
gem 'log4r',            '1.0.5'
gem 'user-choices',     '1.1.6'
gem 'fizx-thread_pool', '0.3.1'
gem 'extlib',           '0.9.12'

require 'drb'
require 'log4r'
require 'user-choices'
require 'thread_pool'
require 'extlib'

# require 'ruby-debug'

include FileUtils::Verbose

Dir.glob(File.join(File.dirname(__FILE__), 'primes/**/*.rb')).each do |name| 
  require name
end
