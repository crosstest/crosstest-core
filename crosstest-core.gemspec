# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crosstest/core/version'

Gem::Specification.new do |spec|
  spec.name          = 'crosstest-core'
  spec.version       = Crosstest::Core::VERSION
  spec.authors       = ['Max Lincoln']
  spec.email         = ['max@devopsy.com']
  spec.summary       = 'Shared code for crosstest projects.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'cause', '~> 0.1'
  spec.add_dependency 'rouge', '~> 1.7'
  spec.add_dependency 'hashie', '~> 3.0'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-notes'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.18', '<= 0.27'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.2'
  spec.add_development_dependency 'aruba'
end
