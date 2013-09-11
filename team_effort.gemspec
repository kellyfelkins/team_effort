# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'team_effort/version'

Gem::Specification.new do |spec|
  spec.name          = "team_effort"
  spec.version       = TeamEffort::VERSION
  spec.authors       = ["Kelly Felkins"]
  spec.email         = ["kelly@restlater.com"]
  spec.description = <<-EOT
    Team Effort provides a simple wrapper to ruby's process management for 
    processing a collection of items in parallel with child processes.
  EOT
  spec.summary       = %q{Use child processes to process a collection in parallel}
  spec.homepage      = "https://github.com/kellyfelkins/team_effort"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
