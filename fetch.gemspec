# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fetch/version'

Gem::Specification.new do |s|
  s.name          = "fetch"
  s.version       = Fetch::VERSION
  s.authors       = ["Lasse Bunk"]
  s.email         = ["lassebunk@gmail.com"]
  s.summary       = %q{Coming}
  s.description   = %q{Coming}
  s.homepage      = "https://github.com/lassebunk/fetch"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^test/})
  s.require_paths = ["lib"]

  s.add_dependency "typhoeus", ">= 0.6.0"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "json"
end
