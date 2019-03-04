require 'fastlane/action'
require_relative '../helper/options'
require_relative '../helper/downloader'

module Fastlane
  module Actions
    class SftpDownloadAction < Action
      def self.run(params)
        # sh 'bundle exec rubocop -D'
        FastlaneCore::PrintTable.print_values(config: params, hide_keys: [:server_password], mask_keys: [:server_key, :server_key_passphrase], title: "SFTP Download #{Sftp::VERSION} Summary")

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
        # Optional:
        "TODO"
      end

      def self.available_options
        Sftp::Options.available_options_download
      end

      def self.authors
        ['oklimberg@gmail.com']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
