# sftp plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-sftp)
[![Gem](https://img.shields.io/gem/v/fastlane-plugin-sftp.svg?style=flat)](http://rubygems.org/gems/fastlane-plugin-sftp)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/oklimberg/fastlane-plugin-sftp/blob/master/LICENSE)
[![Build Status](https://github.com/oklimberg/fastlane-plugin-sftp/actions/workflows/ci.yml/badge.svg)](https://github.com/oklimberg/fastlane-plugin-sftp/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/oklimberg/fastlane-plugin-sftp/badge.svg?branch=master)](https://coveralls.io/github/oklimberg/fastlane-plugin-sftp?branch=master)
[![Twitter: @oklimberg](https://img.shields.io/badge/contact-@oklimberg-blue.svg?style=flat)](https://twitter.com/oklimberg)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-sftp`, add it to your project by running:

```bash
fastlane add_plugin sftp
```

## About sftp

This plugin provides two actions to either upload files to a SFTP server or to download them.
It is inspired by the plugin [apprepo](https://github.com/suculent/apprepo) by Matej Sychra.
Since the apprepo plugin did not provide the possibility to provide a password for the RSA key fie, I
decided to write this plugin

## Actions

### sftp_upload

This action can be used, to upload multiple files or even complete folders to a SFTP server.
You can eiter provide a password via `server_password` or specify the path to a key file via `server_key`. If your keyfile has a password set, you can specify this via `server_key_passphrase`.

``` ruby
sftp_upload(
  server_url: "example.host.com",
  server_user: "john_doe",
  server_key: "#{Dir.home}/.ssh/id_rsa",
  target_dir: "remote/path/on/server", 
  file_paths:["test_file_01.txt", "test_file_02.txt", "test_folder_01"],
)
```

When uploading a folder, the source folder and ists contents will be placed inside the target dir on the remote server.

### sftp_download

This action can be used to download files or folders from a remote server. The parameters are teh same as for `sftp_upload` but the `target_dir` parameter specifies a local folder where all filles should be stored and the `file_paths` parameter specifies the path to the files or folders which should be downloaded.

``` ruby
sftp_download(
  server_url: "example.host.com",,
  server_user: "john_doe",
  server_password: "secret"
  target_dir: "local/folder",
  file_paths:["path/to/remote_file_01.txt","path/to/remote_folder"],
)
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.