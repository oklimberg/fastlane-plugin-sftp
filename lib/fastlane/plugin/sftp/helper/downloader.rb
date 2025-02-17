# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require 'net/sftp'
require 'fastlane_core'
require 'fastlane_core/languages'

require_relative 'options'

module Fastlane
  module Sftp
    # Responsible for performing download SFTP operation
    class Downloader
      attr_accessor :options, :host, :port, :user, :password, :rsa_keypath,
                    :rsa_keypath_passphrase, :target_dir, :root_path, :files

      def initialize(options)
        self.options = options unless options.nil?
        self.host = options[:server_url]
        self.port = options[:server_port]
        self.user = options[:server_user]
        self.password = options[:server_password]
        self.rsa_keypath = options[:server_key]
        self.rsa_keypath_passphrase = options[:server_key_passphrase]
        self.files = options[:file_paths]
        self.target_dir = options[:target_dir]
      end

      #
      # Download files
      #

      def download
        # Login & Download all files using RSA key or username/password
        UI.message('download...')
        session = Helper::SftpHelper.login(host, port, user, password, rsa_keypath, rsa_keypath_passphrase)
        UI.message('Downloading files...')

        session.sftp.connect do |sftp|
          downloads = sftp_download(sftp, files, target_dir)
          downloads.each(&:wait)

          # Lists the entries in a directory for verification
          Dir.entries(target_dir).each do |entry|
            UI.message(entry)
          end
        end
        session.close
        true
      end

      private

      def sftp_download(sftp, source_files, target_dir)
        Dir.mkdir(target_dir) unless Dir.exist?(target_dir)
        downloads = []
        source_files.each do |source|
          UI.message('Checking remote file')
          UI.message("remote path #{source}")
          attrs = sftp.stat!(source)
          if attrs.directory?
            children = []
            sftp.dir.glob(source, '*') do |child|
              remote_path = File.join(source, child.name)
              children.push(remote_path)
            end
            new_target = File.join(target_dir, File.basename(source))
            downloads.concat(sftp_download(sftp, children, new_target))
          else
            download = download_file(sftp, source, Helper::SftpHelper.get_target_file_path(source, target_dir))
            downloads.push(download) unless download.nil?
          end
        rescue StandardError => e
          UI.message("download for path #{source} failed: #{e}")
        end
        downloads
      end

      # Downloads remote file
      #
      # @param sftp
      # @param [String] remote_file_path
      # @param [String] local_file_path
      def download_file(sftp, remote_file_path, local_file_path)
        UI.success('Loading remote file:')
        sftp.download(remote_file_path, local_file_path) do |event, _uploader, *_args|
          case event
          when :open then
            UI.message("starting download of file #{remote_file_path} to #{local_file_path}")
          when :finish then
            UI.success("download of file #{remote_file_path} to #{local_file_path} successful")
          end
        end
      end
    end
  end
end
