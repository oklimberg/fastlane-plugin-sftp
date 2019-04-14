require 'fastlane_core'

module Fastlane
  module Sftp
    # Provides available options for the commands generator
    class Options
      def self.general_options
        return [
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       short_option: '-r',
                                       optional: false,
                                       env_name: 'SERVER_URL',
                                       description: 'URL of your server'),
          FastlaneCore::ConfigItem.new(key: :server_user,
                                       short_option: '-u',
                                       optional: false,
                                       env_name: 'SERVER_USER',
                                       description: 'USER of your server'),
          FastlaneCore::ConfigItem.new(key: :server_password,
                                       short_option: '-p',
                                       optional: true,
                                       env_name: 'SERVER_PASSWORD',
                                       description: 'PASSWORD for your server (not for production)',
                                       conflicting_options: [:server_key],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'server_password' and '#{value.key}' options in one run.")
                                       end),
          FastlaneCore::ConfigItem.new(key: :server_key,
                                       short_option: '-k',
                                       optional: true,
                                       env_name: 'SERVER_KEY',
                                       description: 'RSA key for your server',
                                       conflicting_options: [:server_password],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'server_key' and '#{value.key}' options in one run.")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("Key file '#{value}' does not exist") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :server_key_passphrase,
                                       short_option: '-v',
                                       optional: true,
                                       env_name: 'SERVER_KEY_PASSPHRASE',
                                       description: 'Optional passphrase for the RSA key for your server. If required but not provided, user will be asked for')
          FastlaneCore::ConfigItem.new(
            key: :server_port,
            short_option: '-t',
            optional: true,
            env_name: 'SERVER_PORT',
            type: Integer,
            description: 'PORT used to connect to the server. Defaults to 22',
            default_value: 22
          ),
        ]
      end

      def self.available_options_upload
        return [].concat(general_options).concat(
          [
            FastlaneCore::ConfigItem.new(key: :target_dir,
                                          short_option: '-x',
                                          description: 'target path on the server relative to the home directory of the user'),
            FastlaneCore::ConfigItem.new(key: :file_paths,
                                          short_option: '-j',
                                          description: 'List of files/folders to upload',
                                          type: Array,
                                          verify_block: proc do |value|
                                            UI.user_error!("you must provide at least one file to upload") if value.empty?
                                            value.each { |entry| UI.user_error!("file '#{entry}' does not exist") unless File.exist?(entry) }
                                          end),
          ]
        )
      end

      def self.available_options_download
        return [].concat(general_options).concat(
          [
            FastlaneCore::ConfigItem.new(key: :target_dir,
                                          short_option: '-x',
                                          optional: true,
                                          description: 'local target path to a folder where all downloaded files should be put'),
            FastlaneCore::ConfigItem.new(key: :file_paths,
                                          short_option: '-j',
                                          description: 'List of remote files/folders to download relative to the home directory of the user',
                                          type: Array,
                                          verify_block: proc do |value|
                                            UI.user_error!("you must provide at least one file to download") if value.empty?
                                          end),
          ]
        )
      end
    end
  end
end
