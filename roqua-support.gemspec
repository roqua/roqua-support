# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roqua-support/version'

Gem::Specification.new do |gem|
  gem.name          = "roqua-support"
  gem.version       = Roqua::Support::VERSION
  gem.summary       = %q{Helper objects and proxies used by a lot of RoQua applications}
  gem.description   = %q{Logging backend, freedom patches, }
  gem.license       = "MIT"
  gem.authors       = ["Marten Veldthuis"]
  gem.email         = "marten@roqua.nl"
  gem.homepage      = "https://github.com/roqua/roqua-support"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '>= 3.2', '< 5.1'
  gem.add_dependency 'naught', '~> 1.0'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '>= 2.12.0', '< 4.0'
end
