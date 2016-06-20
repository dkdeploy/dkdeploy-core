Feature: Test tasks for namespace 'project_version'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And the project is deployed

	Scenario: upload the project version file
		Given a file named "Version" with:
		"""
		1.0.0
		"""
		And I successfully run `cap dev project_version:update`
		Then the remote file "current_path/Version" should contain exactly:
		"""
		1.0.0
		"""

	Scenario: update the project version file
		Given a remote file named "Version" with:
		"""
		1.0.0
		"""
		And a file named "Version" with:
		"""
		2.0.0
		"""
		And I successfully run `cap dev project_version:update`
		Then the remote file "current_path/Version" should contain exactly:
		"""
		2.0.0
		"""

	Scenario: change version file path and update the local version file
		Given a remote directory named "current_path/version_file_directory"
		And a file named "Version" with:
		"""
		1.0.0
		"""
		When I extend the development capistrano configuration variable version_file_path with value 'version_file_directory'
		And I successfully run `cap dev project_version:update`
		Then a remote file named "current_path/version_file_directory/Version" should exist
