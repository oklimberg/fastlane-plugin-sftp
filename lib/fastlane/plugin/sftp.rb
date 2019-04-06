require 'fastlane/plugin/sftp/version'

require 'fastlane'
require 'fastlane_core'

module Fastlane
  module Sftp
    # Return all .rb files inside the "actions" and "helper" directory
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::Sftp.all_classes.each do |current|
  require current
end
