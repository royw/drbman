# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{drbman}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Roy Wright"]
  s.date = %q{2009-07-11}
  s.default_executable = %q{drbman}
  s.email = %q{roy@wright.org}
  s.executables = ["drbman"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/drbman",
     "examples/primes/VERSION",
     "examples/primes/bin/primes",
     "examples/primes/lib/primes.rb",
     "examples/primes/lib/primes/cli.rb",
     "examples/primes/lib/primes/drb_server/prime_helper.rb",
     "examples/primes/lib/primes/primes.rb",
     "examples/primes/lib/primes/sieve_of_eratosthenes.rb",
     "examples/primes/reports/calltree.profile",
     "examples/primes/reports/flat.profile",
     "examples/primes/reports/graph.profile",
     "examples/primes/spec/primes_spec.rb",
     "lib/drbman.rb",
     "lib/drbman/cli.rb",
     "lib/drbman/drbman.rb",
     "lib/drbman/host_machine.rb",
     "spec/drbman_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/royw/drbman}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Support for running ruby tasks via drb (druby) on multiple cores and/or systems.}
  s.test_files = [
    "spec/drbman_spec.rb",
     "spec/spec_helper.rb",
     "examples/primes/lib/primes/cli.rb",
     "examples/primes/lib/primes/drb_server/prime_helper.rb",
     "examples/primes/lib/primes/primes.rb",
     "examples/primes/lib/primes/sieve_of_eratosthenes.rb",
     "examples/primes/lib/primes.rb",
     "examples/primes/spec/primes_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<log4r>, ["= 1.0.5"])
      s.add_runtime_dependency(%q<user-choices>, ["= 1.1.6"])
      s.add_runtime_dependency(%q<extlib>, ["= 0.9.12"])
      s.add_runtime_dependency(%q<versionomy>, ["= 0.0.4"])
      s.add_runtime_dependency(%q<net-ssh>, ["= 2.0.11"])
      s.add_runtime_dependency(%q<net-scp>, ["= 1.0.2"])
    else
      s.add_dependency(%q<log4r>, ["= 1.0.5"])
      s.add_dependency(%q<user-choices>, ["= 1.1.6"])
      s.add_dependency(%q<extlib>, ["= 0.9.12"])
      s.add_dependency(%q<versionomy>, ["= 0.0.4"])
      s.add_dependency(%q<net-ssh>, ["= 2.0.11"])
      s.add_dependency(%q<net-scp>, ["= 1.0.2"])
    end
  else
    s.add_dependency(%q<log4r>, ["= 1.0.5"])
    s.add_dependency(%q<user-choices>, ["= 1.1.6"])
    s.add_dependency(%q<extlib>, ["= 0.9.12"])
    s.add_dependency(%q<versionomy>, ["= 0.0.4"])
    s.add_dependency(%q<net-ssh>, ["= 2.0.11"])
    s.add_dependency(%q<net-scp>, ["= 1.0.2"])
  end
end
