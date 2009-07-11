require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "drbman"
    gem.summary = 'Support for running ruby tasks via drb (druby) on multiple cores and/or systems.'
    gem.email = "roy@wright.org"
    gem.homepage = "http://github.com/royw/drbman"
    gem.authors = ["Roy Wright"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.add_dependency('log4r',         '1.0.5')
    gem.add_dependency('user-choices',  '1.1.6')
    gem.add_dependency('extlib',        '0.9.12')
    gem.add_dependency('versionomy',    '0.0.4')
    gem.add_dependency('net-ssh',       '2.0.11')
    gem.add_dependency('net-scp',       '1.0.2')
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "drbman #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

