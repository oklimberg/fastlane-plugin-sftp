# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require 'net/sftp'
require 'fastlane_core'
require 'fastlane_core/languages'

require_relative 'options'

module Fastlane
  module Sftp
    # Responsible for performing upload SFTP operations
    class Uploader
      attr_accessor :options, :host, :port, :user, :password, :rsa_keypath,
                    :rsa_keypath_passphrase, :target_dir, :root_path, :files,
                    :delete_target_dir

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
        self.delete_target_dir = options[:delete_target_dir]
      end

      #
      # Upload files
      #

      def upload
        # Login & Upload all files using RSA key or username/password
        UI.message('upload...')

        session = Helper::SftpHelper.login(host, port, user, password, rsa_keypath, rsa_keypath_passphrase)
        UI.message('Uploading files...')

        session.sftp.connect do |sftp|
          Helper::SftpHelper.remote_rmdir(sftp, target_dir) if delete_target_dir
          Helper::SftpHelper.remote_mkdir(sftp, target_dir)
          uploads = []
          files.each do |file|
            next unless Helper::SftpHelper.check_file(file)

            re = Helper::SftpHelper.get_target_file_path(file, target_dir)
            Helper::SftpHelper.remote_mkdir(sftp, re) if File.directory?(file)
            uploads.push(upload_file(sftp, file, re))
          end
          uploads.each(&:wait)

          begin
            # Lists the entries in a directory for verification
            sftp.dir.foreach(target_dir) do |entry|
              UI.message(entry.longname)
            end
          rescue StandardError => e
            UI.message("Failed to load files: #{e}")
          end
        end
        session.close
        true
      end

      private

      # Upload file
      #
      # @param sftp
      # @param [String] local_file_path
      # @param [String] remote_file_path
      def upload_file(sftp, local_file_path, remote_file_path)
        type = if File.file?(local_file_path)
                 'file'
               else
                 'folder'
               end
        UI.message("starting upload of #{type} #{local_file_path} to #{remote_file_path}")
        sftp.upload(local_file_path, remote_file_path) do |event, _uploader, *args|
          case event
          when :mkdir then
            # args[0] : remote path name
            UI.message("creating directory #{args[0]}")
          when :open then
            file = args[0]
            UI.message("starting upload of #{file.local} to #{file.remote}")
          when :close then
            file = args[0]
            UI.message("finished with #{file.remote}")
          when :finish then
            UI.success("upload of #{type} #{local_file_path} to #{remote_file_path} successful")
          end
        end
      end
    end
  end
end
