# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aspekt-sentiment/version'

Gem::Specification.new do |spec|
  spec.name          = "aspekt-sentiment"
  spec.version       = Aspekt::VERSION
  spec.authors       = ["Dylan Hanning", "Charlie Egan"]
  spec.email         = ["dylanhanning123@hotmail.com"]

  spec.summary       = "Simple aspect-level sentiment analysis."
  spec.description   = "A highly-customisable gem that provides simple aspect-level sentiment analysis using custom dictionaries. Based on Rescore: https://github.com/charlieegan3/rescore"
  spec.homepage      = "https://github.com/IllegalCactus/aspekt-sentiment"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency 'punkt-segmenter'
end
