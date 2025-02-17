# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/options'
require_relative '../helper/uploader'

module Fastlane
  module Actions
    class SftpUploadAction < Action
      def self.run(params)
        # sh 'bundle exec rubocop -D'
        FastlaneCore::PrintTable.print_values(config: params, mask_keys: [:server_password, :server_key, :server_key_passphrase], title: "SFTP Upload #{Sftp::VERSION} Summary")

        UI.success('SFTP Uploader running...')
        uploader = Sftp::Uploader.new(params)
        result = uploader.upload
        msg = 'Upload failed. Check out the error above.'
        UI.user_error!(msg) unless result
        UI.success('Finished the upload.')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'upload files to a remote Server via SFTP'
      end

      def self.details
        "More information: https://github.com/oklimberg/fastlane-plugin-sftp/"
      end

      def self.available_options
        Sftp::Options.available_options_upload
      end

      def self.author
        'oklimberg'
      end

      # rubocop:disable Lint/UnusedMethodArgument
      # rubocop:disable Naming/PredicateName
      def self.is_supported?(platform)
        true
      end
      # rubocop:enable Lint/UnusedMethodArgument
      # rubocop:enable Naming/PredicateName

      def self.category
        :misc
      end
    end
  end
end
