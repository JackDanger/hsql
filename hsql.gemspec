# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hsql/version'

Gem::Specification.new do |spec|
  spec.name          = 'hsql'
  spec.version       = HSQL::VERSION
  spec.authors       = ['Jack Danger Canty']
  spec.email         = ['gems@jackcanty.com']

  spec.summary       = 'Store a hash of data with your SQL queries.'
  spec.description   = 'Write SQL queries with Mustache and easily render them for specific dates/times'
  spec.homepage      = 'https://github.com/JackDanger/hsql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['hsql']
  spec.require_paths = ['lib']

  spec.add_dependency 'mustache', '> 0'
  spec.add_dependency 'activesupport', '> 0'
  spec.add_dependency 'pg_query', '>= 0.6.4'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rubocop', '~> 0.3'
  spec.add_development_dependency 'rake', '> 0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'timecop', '~> 0.8.0'
  spec.add_development_dependency 'pry-byebug', '> 3'
end
