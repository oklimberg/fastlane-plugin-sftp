describe Fastlane::Actions::SftpDownloadAction do
  after(:each) do
    ENV["DEBUG"] = "0"
    FileUtils.remove_dir("down") if File.directory?("down")
    FileUtils.remove_dir("fastlane/down") if File.directory?("fastlane/down")
  end

  describe '#run' do
    it 'raise an error because specifying server_password and server_key' do
      expect do
        # debug mode must be enabled before running the first test to see all fastlane output
        # ENV["DEBUG"] = "1"
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
      end.to raise_error("You can't use 'server_password' and 'server_key' options in one run.")
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
      end.to raise_error("You can't use 'server_key' and 'server_password' options in one run.")
    end

    it 'raise an error because of an invalid key file path' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_download(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_key: '/assets/keys/valid_key_no_pass',
            target_dir: 'down',
            file_paths: ['download/file_01.txt', 'download/file_02.txt', 'download/file_does_not_exist.txt', 'download/sub_folder']
          )
        end").runner.execute(:test)
      end.to raise_error("Key file '/assets/keys/valid_key_no_pass' does not exist")
    end

    it('raise an error because of empty list of files to download') {
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_download(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_key: '../assets/keys/valid_key_no_pass',
            target_dir: 'down',
            file_paths: []
          )
        end").runner.execute(:test)
      end.to raise_error("you must provide at least one file to download")
    }

    it 'downloads files from a SFTP server' do
      # ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpDownloadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
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
      expect(File).to exist("fastlane/down/file_01.txt")
      expect(File).to exist("fastlane/down/file_02.txt")
      expect(File).to exist("fastlane/down/sub_folder/file_03.txt")
      expect(File).to exist("fastlane/down/sub_folder/file_04.txt")
    end
  end

  describe('metadata') do
    it('check metadata of action sftp_download') {
      expect(Fastlane::Actions::SftpDownloadAction.description).to(eq("download files from a remote Server via SFTP"))
      expect(Fastlane::Actions::SftpDownloadAction.details).to(eq("More information: https://github.com/oklimberg/fastlane-plugin-sftp/"))
      expect(Fastlane::Actions::SftpDownloadAction.author).to(eq("oklimberg"))
      expect(Fastlane::Actions::SftpDownloadAction.is_supported?(:ios)).to(be(true))
      expect(Fastlane::Actions::SftpDownloadAction.is_supported?(:android)).to(be(true))
      expect(Fastlane::Actions::SftpDownloadAction.is_supported?(:mac)).to(be(true))
      expect(Fastlane::Actions::SftpDownloadAction.category).to(be(:misc))
    }
  end
end
