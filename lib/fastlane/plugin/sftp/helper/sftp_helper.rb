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

      def self.login(host, user, password, rsa_keypath, rsa_keypath_passphrase)
        if host.nil? || user.nil?
          UI.user_error('server_url, server_user and server_password or server_key must be set')
          return nil
        end

        if rsa_keypath
          rsa_key = Helper::SftpHelper.load_rsa_key(rsa_keypath)
          if rsa_key.nil?
            UI.user_error("Failed to load RSA key... #{rsa_keypath}")
          end
        end

        if !rsa_key.nil?
          UI.message('Logging in with RSA key...')
          session = Net::SSH.start(host, user, key_data: rsa_key, keys_only: true, passphrase: rsa_keypath_passphrase)
        else
          UI.message('Logging in with username/password...')
          session = Net::SSH.start(host, user, password: password)
        end
        return session
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
        return File.join(target_dir, File.basename(source_file_path))
      end

      def self.remote_mkdir(sftp, remote_path)
        sftp.mkdir(remote_path)
      rescue Net::SFTP::StatusException => e
        raise if e.code != 11
        UI.message("Remote dir #{remote_path} exists.")
      end

      def self.load_rsa_key(rsa_keypath)
        File.open(rsa_keypath, 'r') do |file|
          rsa_key = [file.read]
          if !rsa_key.nil?
            UI.success('Successfully loaded RSA key...')
          else
            UI.user_error!('Failed to load RSA key...')
          end
          rsa_key
        end
      end

      def self.generate_remote_path(user, target_dir)
        path = File.join('/', user, target_dir)
        if user != "root"
          path = File.join('/home', path)
        end
        path
      end
    end
  end
end
