# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fastlane/plugin/sftp/version'

Gem::Specification.new do |spec|
  spec.name                  = 'fastlane-plugin-sftp'
  spec.version               = Fastlane::Sftp::VERSION
  spec.author                = 'Oliver Limberg'
  spec.email                 = 'oklimberg@gmail'

  spec.summary               = 'Plugin to upload files via SFTP'
  spec.homepage              = "https://github.com/oklimberg/fastlane-plugin-sftp"
  spec.license               = "MIT"

  spec.required_ruby_version = '>= 2.6.0'
  spec.files                 = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files            = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths         = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency('your-dependency', '~> 1.0.0')
  spec.add_dependency('bcrypt_pbkdf')
  spec.add_dependency('ed25519')
  spec.add_dependency('net-sftp')
  spec.add_dependency('net-ssh', '~> 7.2.0')

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('coveralls')
  spec.add_development_dependency('fastlane', '>= 2.116.0')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov', '>= 0.22.0')
end
