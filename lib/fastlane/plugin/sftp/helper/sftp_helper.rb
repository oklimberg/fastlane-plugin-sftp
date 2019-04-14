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

      def self.login(host, user, password, rsa_keypath, rsa_keypath_passphrase, port)
        if host.nil? || user.nil? || (password.nil? && rsa_keypath.nil?)
          UI.user_error!('server_url, server_user and server_password or server_key must be set')
        end

        if rsa_keypath
          # will raise an excetion if file is empty
          rsa_key = Helper::SftpHelper.load_rsa_key(rsa_keypath)
        end

        logging_level = :warn
        if ENV["DEBUG"] == "1"
          logging_level = :debug
        end
        options = {
          verbose: logging_level,
          non_interactive: true
        }
        if !rsa_key.nil?
          UI.message('Logging in with RSA key...')
          options = options.merge({
            key_data: rsa_key,
            keys_only: true,
            passphrase: rsa_keypath_passphrase,
            auth_methods: ["publickey"]
          })
        else
          UI.message('Logging in with username/password...')
          options = options.merge({
            password: password,
            auth_methods: ["password"]
          })
        end
        if !port.nil? 
          UI.message("Using custom port #{port}...")
          options = options.merge({
            port: port
          })
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
        return File.join(target_dir, File.basename(source_file_path))
      end

      def self.remote_mkdir(sftp, remote_path)
        sftp.mkdir!(remote_path)
      rescue Net::SFTP::StatusException => e
        # the returned code depends on the implementation of the SFTP server
        # we handle code FX_FILE_ALREADY_EXISTS and FX_FAILURE the same
        codes = Net::SFTP::Constants::StatusCodes
        raise if e.code != codes::FX_FAILURE && e.code != codes::FX_FILE_ALREADY_EXISTS
        UI.message("Remote dir #{remote_path} exists.")
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

      def self.generate_remote_path(user, target_dir)
        path = File.join('/', user, target_dir)
        if user != "root"
          path = File.join('/home', path)
        end
        return path
      end
    end
  end
end
