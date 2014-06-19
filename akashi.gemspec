# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'akashi/version'

Gem::Specification.new do |spec|
  spec.name          = "akashi"
  spec.version       = Akashi::VERSION
  spec.authors       = ["asonas", "int_remain"]
  spec.email         = ["hzw1258@gmail.com", "ponde.ponde.ponde@gmail.com"]
  spec.description   = %q{Wrapping aws-sdk}
  spec.summary       = %q{Wrapping awd-sdk}
  spec.homepage      = "https://github.com/spice-life/akashi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
