# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fastlane/plugin/sftp/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-sftp'
  spec.version       = Fastlane::Sftp::VERSION
  spec.author        = 'Oliver Limberg'
  spec.email         = 'o.limberg@portrix.net'

  spec.summary       = 'Plugin to upload files via SFTP'
  spec.homepage      = "https://github.com/oklimberg/fastlane-plugin-sftp"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency('your-dependency', '~> 1.0.0')
  spec.add_dependency('net-ssh', '~> 4.0', '>= 4.0.0')
  spec.add_dependency('net-sftp', '~> 2.1', '>= 2.1.2')

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.116.0')
end
