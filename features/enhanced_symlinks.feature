Feature: Test enhanced symlink tasks

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And a remote empty file named "shared_path/sample/sample_file"
		And a remote directory named "shared_path/sample_folder"
		When I extend the development capistrano configuration variable enhanced_linked_files with value { 'sample/sample_file' => 'works/fine' }
		And I extend the development capistrano configuration variable enhanced_linked_dirs with value { 'sample_folder' => 'fine/as_well' }

	Scenario: Check enhanced symlinking of files
		When I successfully run `cap dev deploy`
		Then a remote file named "current_path/works/fine" should exist

	Scenario: Check enhanced symlinking of directories
		When I successfully run `cap dev deploy`
		Then a remote directory named "current_path/fine/as_well" should exist
