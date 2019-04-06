describe Fastlane::Helper::SftpHelper do
  describe '#check_file' do
    it 'check file exists: true' do
      # ENV["DEBUG"] = "1"
      result = Fastlane::Helper::SftpHelper.check_file("assets/test_file_01.txt")
      expect(result).to be(true)
    end

    it 'check file exists: false' do
      # ENV["DEBUG"] = "1"
      result = Fastlane::Helper::SftpHelper.check_file("assets/test_file_does_not_exist.txt")
      expect(result).to be(false)
    end
  end

  describe '#login' do
    it 'raise error because of missing host' do
      expect do
        Fastlane::Helper::SftpHelper.login(nil, "user", "password", nil, nil)
      end.to raise_exception('server_url, server_user and server_password or server_key must be set')
    end

    it 'raise error because of missing user' do
      expect do
        Fastlane::Helper::SftpHelper.login("host", nil, "password", nil, nil)
      end.to raise_exception('server_url, server_user and server_password or server_key must be set')
    end

    it 'raise error because of missing password and RSA key file path' do
      expect do
        Fastlane::Helper::SftpHelper.login("host", "user", nil, nil, nil)
      end.to raise_exception('server_url, server_user and server_password or server_key must be set')
    end

    it 'succeed with user & password' do
      sftp = Fastlane::Helper::SftpHelper.login("sftp.server.example", "sftp_test", "password", nil, nil)
      expect(sftp).not_to(be_nil)
    end

    it 'succeed with user & RSA key file without pass' do
      sftp = Fastlane::Helper::SftpHelper.login("sftp.server.example", "sftp_test", nil, "assets/keys/valid_key_no_pass", nil)
      expect(sftp).not_to(be_nil)
    end

    it 'succeed with user & RSA key file with pass' do
      sftp = Fastlane::Helper::SftpHelper.login("sftp.server.example", "sftp_test", nil, "assets/keys/valid_key_with_pass", "passphrase")
      expect(sftp).not_to(be_nil)
    end

    it 'fail with user & RSA key file with pass' do
      expect do
        Fastlane::Helper::SftpHelper.login("sftp.server.example", "sftp_test", nil, "assets/keys/valid_key_with_pass", "wrong")
      end.to(raise_exception("Decrypt failed on private key"))
    end
  end
end
