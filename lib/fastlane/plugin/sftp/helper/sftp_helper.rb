# frozen_string_literal: true

require 'fastlane_core/ui/ui'
require 'net/ssh'
require 'net/sftp'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SftpHelper
      # class methods that you define here become available in your action
      # as `Helper::SftpHelper.your_method`
      #

      def self.login(host, port, user, password, rsa_keypath, rsa_keypath_passphrase)
        missing_param = host.nil? || user.nil? || (password.nil? && rsa_keypath.nil?)
        UI.user_error!('server_url, server_user and server_password or server_key must be set') if missing_param

        if rsa_keypath
          # will raise an excetion if file is empty
          rsa_key = Helper::SftpHelper.load_rsa_key(rsa_keypath)
        end

        logging_level = :warn
        logging_level = :debug if ENV["DEBUG"] == "1"
        options = {
          verbose: logging_level,
          non_interactive: true
        }
        unless port.nil?
          UI.message("Using custom port #{port}...")
          options[:port] = port
        end
        if !rsa_key.nil?
          UI.message('Logging in with RSA key...')
          options = options.merge(
            {
              key_data: rsa_key,
              keys_only: true,
              passphrase: rsa_keypath_passphrase,
              auth_methods: ["publickey"]
            }
          )
        else
          UI.message('Logging in with username/password...')
          options = options.merge(
            {
              password: password,
              auth_methods: ["password"]
            }
          )
        end
        return Net::SSH.start(host, user, options)
      end

      # Check file existence locally
      #
      # @param local_file_path
      def self.check_file(local_file_path)
        if File.exist?(local_file_path)
          UI.verbose('File found at ' + local_file_path)
          return true
        else
          UI.important("File at given path #{local_file_path} does not exist. File will be ignored")
          return false
        end
      end

      def self.get_target_file_path(source_file_path, target_dir)
        return File.basename(source_file_path) if target_dir.nil? || target_dir.empty?

        return File.join(target_dir, File.basename(source_file_path))
      end

      def self.remote_mkdir(sftp, remote_path)
        return if remote_path.nil? || remote_path.empty? || remote_dir_exists?(sftp, remote_path)

        path_parts = Pathname(remote_path).each_filename.to_a
        UI.message("Pathparts = #{path_parts}")
        path_value = remote_path.start_with?("/") ? "" : "."
        path_parts.each do |path|
          begin
            path_value = path_value + File::SEPARATOR + path
            UI.message("creating #{path_value}")
            sftp.mkdir!(path_value)
          rescue Net::SFTP::StatusException => e
            # ignoring all errors while creating sub paths
            UI.message("operation failed: #{e.message}")
          end
        end

        # check for existence again
        folder_exists = remote_dir_exists?(sftp, remote_path)
        UI.user_error!("remote folder #{remote_path} does not exist and could not be created") unless folder_exists
      end

      def self.remote_rmdir(sftp, remote_path)
        return unless remote_dir_exists?(sftp, remote_path)

        # make sure the remote directory is empty
        sftp.dir.entries(remote_path).each do |entry|
          next if entry.name == "." || entry.name == ".."

          path_value = remote_path + File::SEPARATOR + entry.name
          UI.message("entry #{path_value}")
          begin
            if entry.directory?
              remote_rmdir(sftp, path_value)
            else
              sftp.remove!(path_value)
            end
          rescue Net::SFTP::StatusException => e
            UI.user_error!("could not delete file #{path_value}: #{e.message}")
          end
        end

        begin
          sftp.rmdir!(remote_path)
        rescue Net::SFTP::StatusException => e
          UI.user_error!("Could not delete remote directory #{remote_path}: #{e.message}")
        end

        # check for existence again
        folder_exists = remote_dir_exists?(sftp, remote_path)
        UI.user_error!("remote folder #{remote_path} still exists after deletion") if folder_exists
      end

      def self.remote_dir_exists?(sftp, remote_path)
        UI.message("Checking remote directory #{remote_path}")
        attrs = sftp.stat!(remote_path)
        UI.user_error!("Path #{remote_path} is not a directory") unless attrs.directory?
        return true
      rescue Net::SFTP::StatusException => e
        # directory does not exist, we have to create it
        codes = Net::SFTP::Constants::StatusCodes
        raise if e.code != codes::FX_NO_SUCH_FILE && e.code != codes::FX_NO_SUCH_PATH

        UI.message("Remote directory #{remote_path} does not exist")
        return false
      end

      def self.load_rsa_key(rsa_keypath)
        UI.user_error!("RSA key file #{rsa_keypath} does not exist") unless check_file(rsa_keypath)

        rsa_key = IO.read(rsa_keypath)
        if !rsa_key.to_s.empty?
          UI.success('Successfully loaded RSA key...')
        else
          UI.user_error!("Failed to load RSA key... #{rsa_keypath}")
        end
        return rsa_key
      end
    end
  end
end
