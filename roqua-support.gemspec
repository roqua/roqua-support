# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roqua-support/version'

Gem::Specification.new do |gem|
  gem.name          = "roqua-support"
  gem.version       = Roqua::Support::VERSION
  gem.authors       = ["Marten Veldthuis"]
  gem.email         = "info@roqua.nl"
  gem.description   = %q{description}
  gem.summary       = %q{summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '~> 3.2'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.12.0'
end
