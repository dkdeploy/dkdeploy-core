Feature: Test tasks for namespace 'utils'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared

	Scenario: Upload local file to server
		Given an empty file named "htdocs/new_file.html"
		Then I successfully run `cap dev utils:upload_file['htdocs/new_file.html']`
		Then a remote file named "current_path/new_file.html" should exist

	Scenario: Upload local file to server which does not exist locally
		And I run `cap dev utils:upload_file['htdocs/new_file.html']`
		Then the exit status should be 1

	Scenario: Call task "utils:upload_file" without entering any file name
		Given an empty file named "htdocs/new_file.html"
		When I run `cap dev utils:upload_file` interactively
		And I type ""
		And I close the stdin stream
		Then the exit status should be 1
		And a remote file named "current_path/new_file.html" should not exist

	Scenario: Download remote file
		Given a remote directory named "current_path"
		And a remote file named "current_path/download_file.txt" with:
		"""
Remote file content
		"""
		When I successfully run `cap dev utils:download_file['download_file.txt']`
		Then a file named "temp/download_file.dkdeploy-core.test.txt" should exist

	Scenario: Download a file from server which does exist locally
		Given a file named "temp/download_file.dkdeploy-core.test.txt" with:
		"""
Local file content
		"""
		And a remote directory named "current_path"
		And a remote file named "current_path/download_file.txt" with:
		"""
Remote file content
		"""
		When I successfully run `cap dev utils:download_file['download_file.txt']`
		Then the file "temp/download_file.dkdeploy-core.test.txt" should contain exactly:
		"""
Remote file content

		"""

	Scenario: Call task "utils:download_file" without entering any file name
		When I run `cap dev utils:download_file` interactively
		And I type ""
		And I close the stdin stream
		Then the exit status should be 1

	Scenario: Rsync add new files to server
		Given the project is deployed
		And an empty file named "htdocs/new_file.txt"
		And I successfully run `cap dev utils:rsync`
		Then a remote file named "current_path/new_file.txt" should exist

	Scenario: Rsync add new files at root to server
		Given the project is deployed
		And I extend the development capistrano configuration variable rsync_path with value '.'
		And an empty file named "new_file.txt"
		And I successfully run `cap dev utils:rsync`
		Then a remote file named "current_path/new_file.txt" should exist

	Scenario: Rsync exclude files
		Given the project is deployed
		And I extend the development capistrano configuration variable rsync_exclude with value ['file_to_exclude.txt']
		And an empty file named "htdocs/file_to_exclude.txt"
		And I successfully run `cap dev utils:rsync`
		Then a remote file named "current_path/file_to_exclude.txt" should not exist

	Scenario: Create custom directories within path shared
		When I run `cap dev utils:create_custom_directories` interactively
		And I type "mydirectory"
		And I close the stdin stream
		Then the exit status should be 0
		And a remote directory named "shared_path/mydirectory" should exist
