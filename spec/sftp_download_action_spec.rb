describe Fastlane::Actions::SftpDownloadAction do
  describe '#run' do
    it 'downloads files from a SFTP server' do
      # ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpDownloadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        # server_password: "password",
        server_key: "assets/keys/valid_key_no_pass",
        target_dir: "down",
        file_paths: ["download/file_01.txt", "download/file_02.txt", "download/file_does_not_exist.txt", "download/sub_folder"]
      )
      expect(File).to exist("down/file_01.txt")
      expect(File).to exist("down/file_02.txt")
      expect(File).to exist("down/sub_folder/file_03.txt")
      expect(File).to exist("down/sub_folder/file_04.txt")
    end

    it 'downloads files inside a Fastlane file' do
      Fastlane::FastFile.new.parse("lane :test do
        sftp_download(
          server_url: 'sftp.server.example',
          server_user: 'sftp_test',
          server_key: '../assets/keys/valid_key_no_pass',
          target_dir: 'down',
          file_paths: ['download/file_01.txt', 'download/file_02.txt', 'download/file_does_not_exist.txt', 'download/sub_folder']
        )
      end").runner.execute(:test)
      expect(File).to exist("down/file_01.txt")
      expect(File).to exist("down/file_02.txt")
      expect(File).to exist("down/sub_folder/file_03.txt")
      expect(File).to exist("down/sub_folder/file_04.txt")
    end

    it 'raise an error because specifying server_password and server_key' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_download(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_password: 'password',
            server_key: '../assets/keys/valid_key_no_pass',
            target_dir: 'down',
            file_paths: ['download/file_01.txt', 'download/file_02.txt', 'download/file_does_not_exist.txt', 'download/sub_folder']
          )
        end").runner.execute(:test)
      end.to raise_error("You can't use 'password' and 'server_key' options in one run.")
    end

    it 'raise an error because specifying server_key and server_password' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_download(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_key: '../assets/keys/valid_key_no_pass',
            server_password: 'password',
            target_dir: 'down',
            file_paths: ['download/file_01.txt', 'download/file_02.txt', 'download/file_does_not_exist.txt', 'download/sub_folder']
          )
        end").runner.execute(:test)
      end.to raise_error("You can't use 'server_key' and 'password' options in one run.")
    end

    it 'raise an error because of an invalid key file path' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_download(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_key: '/assets/keys/valid_key_no_pass',
            server_password: 'password',
            target_dir: 'down',
            file_paths: ['download/file_01.txt', 'download/file_02.txt', 'download/file_does_not_exist.txt', 'download/sub_folder']
          )
        end").runner.execute(:test)
      end.to raise_error("Failed to load RSA key... /assets/keys/valid_key_no_pass")
    end
  end
end
