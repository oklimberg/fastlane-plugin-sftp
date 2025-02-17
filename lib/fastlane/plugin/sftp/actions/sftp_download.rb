require 'fastlane/action'
require_relative '../helper/options'
require_relative '../helper/downloader'

module Fastlane
  module Actions
    class SftpDownloadAction < Action
      def self.run(params)
        # sh 'bundle exec rubocop -D'
        FastlaneCore::PrintTable.print_values(config: params, mask_keys: [:server_password, :server_key, :server_key_passphrase], title: "SFTP Download #{Sftp::VERSION} Summary")

        UI.success('SFTP Downloader running...')
        downloader = Sftp::Downloader.new(params)
        result = downloader.download
        msg = 'Download failed. Check out the error above.'
        UI.user_error!(msg) unless result
        UI.success('Finished the download.')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'download files from a remote Server via SFTP'
      end

      def self.details
        "More information: https://github.com/oklimberg/fastlane-plugin-sftp/"
      end

      def self.available_options
        Sftp::Options.available_options_download
      end

      def self.author
        'oklimberg'
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def self.is_supported?(platform)
        true
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def self.category
        :misc
      end
    end
  end
end
