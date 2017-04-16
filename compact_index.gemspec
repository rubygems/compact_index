# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "compact_index/version"

Gem::Specification.new do |spec|
  spec.name          = "compact_index"
  spec.version       = CompactIndex::VERSION
  spec.authors       = ["fotanus@gmail.com"]
  spec.email         = ["Felipe Tanus"]

  spec.summary       = "Backend for compact index"
  spec.homepage      = "https://github.com/bundler/compact_index"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
end
