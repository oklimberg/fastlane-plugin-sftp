describe Fastlane::Actions::SftpUploadAction do
  after(:each) do
    ENV["DEBUG"] = "0"
  end

  describe '#run' do
    it 'uploads files to a SFTP server using relative target dir' do
      ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        target_dir: "test_01",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt", "assets/test_folder"]
      )
      expect(File).to exist("/home/sftp_test/test_01/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/test_01/test_file_02.txt")
      expect(File).to exist("/home/sftp_test/test_01/test_folder/test_file_03.txt")
      expect(File).to exist("/home/sftp_test/test_01/test_folder/test_file_04.txt")
      expect(File).to exist("/home/sftp_test/test_01/test_folder/test_sub_folder/test_file_05.txt")
    end

    it 'uploads files to a SFTP server using absolut target dir' do
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        target_dir: "/home/sftp_test/test_02",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt", "assets/test_folder"]
      )
      expect(File).to exist("/home/sftp_test/test_02/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/test_02/test_file_02.txt")
      expect(File).to exist("/home/sftp_test/test_02/test_folder/test_file_03.txt")
      expect(File).to exist("/home/sftp_test/test_02/test_folder/test_file_04.txt")
      expect(File).to exist("/home/sftp_test/test_02/test_folder/test_sub_folder/test_file_05.txt")
    end

    it 'uploads files to a SFTP server using absolute target dir outside user home folder' do
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        target_dir: "/var/ftp/sftp_test/super/deep/folder/structure/target/dir",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt", "assets/test_folder"]
      )
      expect(File).to exist("/var/ftp/sftp_test/super/deep/folder/structure/target/dir/test_file_01.txt")
      expect(File).to exist("/var/ftp/sftp_test/super/deep/folder/structure/target/dir/test_file_02.txt")
      expect(File).to exist("/var/ftp/sftp_test/super/deep/folder/structure/target/dir/test_folder/test_file_03.txt")
      expect(File).to exist("/var/ftp/sftp_test/super/deep/folder/structure/target/dir/test_folder/test_file_04.txt")
      expect(File).to exist("/var/ftp/sftp_test/super/deep/folder/structure/target/dir/test_folder/test_sub_folder/test_file_05.txt")
    end
    
    it 'uploads files to root of an SFTP server, without target dir specified' do
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt", "assets/test_folder"]
      )
      expect(File).to exist("/home/sftp_test/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/test_file_02.txt")
      expect(File).to exist("/home/sftp_test/test_folder/test_file_03.txt")
      expect(File).to exist("/home/sftp_test/test_folder/test_file_04.txt")
      expect(File).to exist("/home/sftp_test/test_folder/test_sub_folder/test_file_05.txt")
    end

    it 'uploads files to a SFTP server into existing folder' do
      # ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        target_dir: "existing_upload_folder",
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt"]
      )
      expect(File).to exist("/home/sftp_test/existing_upload_folder/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/existing_upload_folder/test_file_02.txt")
    end

    it 'deletes existing target folder before uploading files to a SFTP server' do
      ENV["DEBUG"] = "1"
      Fastlane::Actions::SftpUploadAction.run(
        server_url: "sftp.server.example",
        server_user: "sftp_test",
        server_password: "password",
        target_dir: "non_empty_folder",
        delete_target_dir: true,
        file_paths: ["assets/test_file_01.txt", "assets/test_file_02.txt"]
      )
      expect(File).to exist("/home/sftp_test/non_empty_folder/test_file_01.txt")
      expect(File).to exist("/home/sftp_test/non_empty_folder/test_file_02.txt")
      expect(File).not_to(exist("/home/sftp_test/non_empty_folder/subfolder/old.txt"))
      expect(File).not_to(exist("/home/sftp_test/non_empty_folder/subfolder"))
      expect(File).not_to(exist("/home/sftp_test/non_empty_folder/old.txt"))
    end

    it('raise an error because of empty list of files to upload') {
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_upload(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_password: 'password',
            target_dir: 'test_03',
            file_paths: []
          )
        end").runner.execute(:test)
      end.to(raise_exception("you must provide at least one file to upload"))
    }

    it('raise an error because of non-existent file to upload') {
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sftp_upload(
            server_url: 'sftp.server.example',
            server_user: 'sftp_test',
            server_password: 'password',
            target_dir: 'test_04',
            file_paths: ['../assets/test_file_does_not_exist.txt']
          )
        end").runner.execute(:test)
      end.to(raise_exception("file '../assets/test_file_does_not_exist.txt' does not exist"))
    }
  end

  describe('metadata') do
    it('check metadata of action sftp_download') {
      expect(Fastlane::Actions::SftpUploadAction.description).to(eq("upload files to a remote Server via SFTP"))
      expect(Fastlane::Actions::SftpUploadAction.details).to(eq("More information: https://github.com/oklimberg/fastlane-plugin-sftp/"))
      expect(Fastlane::Actions::SftpUploadAction.author).to(eq("oklimberg"))
      expect(Fastlane::Actions::SftpUploadAction.is_supported?(:ios)).to(be(true))
      expect(Fastlane::Actions::SftpUploadAction.is_supported?(:android)).to(be(true))
      expect(Fastlane::Actions::SftpUploadAction.is_supported?(:mac)).to(be(true))
      expect(Fastlane::Actions::SftpUploadAction.category).to(be(:misc))
    }
  end
end
