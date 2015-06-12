# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'findbugs_translate_checkstyle_format/version'

Gem::Specification.new do |spec|
  spec.name          = "findbugs_translate_checkstyle_format"
  spec.version       = FindbugsTranslateCheckstyleFormat::VERSION
  spec.authors       = ["noboru-i"]
  spec.email         = ["ishikura.noboru@gmail.com"]

  spec.summary       = %q{Translate findbugs format into checkstyle format.}
  spec.description   = %q{Translate findbugs format into checkstyle format.}
  spec.homepage      = "https://github.com/noboru-i/findbugs_translate_checkstyle_format"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'nori'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "coveralls"
end
