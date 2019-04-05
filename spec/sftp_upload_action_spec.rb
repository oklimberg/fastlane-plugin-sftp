describe Fastlane::Actions::SftpUploadAction do
  describe '#run' do
    it 'uploads files to a SFTP server' do
      # ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        # server_key: "assets/keys/valid_key_no_pass",
        target_dir: "test",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt", "assets/test_folder"]
      )
      expect(File).to exist("/home/sftp_test/test/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/test/test_file_02.txt")
      expect(File).to exist("/home/sftp_test/test/test_folder/test_file_03.txt")
      expect(File).to exist("/home/sftp_test/test/test_folder/test_file_04.txt")
    end
  end
end
