# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hsql/version'

Gem::Specification.new do |spec|
  spec.name          = "hsql"
  spec.version       = Setl::VERSION
  spec.authors       = ["Jack Danger Canty"]
  spec.email         = ["gems@jackcanty.com"]

  spec.summary       = %q{Store a hash of data with your SQL queries.}
  spec.description   = %q{Write SQL queries in a .sql format and ship them with metadata about how they should be executed}
  spec.homepage      = "https://github.com/JackDanger/hsql"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mustache", '> 0'
#  spec.add_dependency 'pg_query', '>= 0.6.2'
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", '> 0'
  spec.add_development_dependency "rspec", '~> 3.3'
  spec.add_development_dependency "pry-byebug", '> 3'
end
