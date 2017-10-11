Feature: Test tasks for namespace 'assets'

	Background:
		Given a test app with the default configuration

	Scenario: Check if compass files are compiled into the configured folder
		Given the remote server is cleared
		And the project is deployed
		And I extend the development capistrano configuration from the fixture file custom_compass_sources.rb
		When I successfully run `cap dev assets:compile_compass`
		Then a file named "htdocs/stylesheets/test1/css/source.css" should exist
		And a file named "htdocs/stylesheets/test2/css/source.css" should exist

	Scenario: Check if compass files are compiled given by command line
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev "assets:compile_compass['htdocs/stylesheets/test1']"`
		Then a file named "htdocs/stylesheets/test1/css/source.css" should exist

	Scenario: Check if compass files are compiled given by command line with arguments
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev "assets:compile_compass['htdocs/stylesheets/test1','--boring']"`
		Then a file named "htdocs/stylesheets/test1/css/source.css" should exist
		And the output should contain "--boring"

	Scenario: Check if compass files are compiled with pre defined arguments
		Given the remote server is cleared
		And the project is deployed
		And I extend the development capistrano configuration variable compass_compile_arguments with value ['--boring', '--environment', 'production']
		When I successfully run `cap dev "assets:compile_compass['htdocs/stylesheets/test1']"`
		Then a file named "htdocs/stylesheets/test1/css/source.css" should exist
		And the output should contain "--boring"

	Scenario: Check if the htpasswd file is created with the correct data
		Given the remote server is cleared
		And I run `cap dev assets:add_htpasswd` interactively
		And I type "dkd_test_user"
		And I type "dkd_test_password"
		And I close the stdin stream
		Then the exit status should be 0
		And a remote file named "shared_path/.htpasswd" should exist

	Scenario: Check if cleanup is really cleaning downloads
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev assets:cleanup`
		Given a remote empty file named "assets_path/download/example.png"
		Then a remote file named "assets_path/download/example.png" should exist
		When I successfully run `cap dev assets:cleanup`
		Then a remote file named "assets_path/download/example.png" should not exist

	Scenario: Check if download is getting archives from the remote server
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev assets:cleanup`
		And a remote empty file named "assets_path/download/example.png"
		And a remote empty file named "assets_path/download/folder/example3.png"
		And I run `cap dev assets:download`
		Then a file named "temp/assets/download.tar.gz" should exist

	Scenario: Check if update is filling the remote server from the local archives
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev assets:cleanup`
		Then a remote empty file named "assets_path/download/file.html"
		And a remote empty file named "assets_path/download/subdirectory/file2.html"
		And a remote empty file named "assets_path/download/file3.html"
		When I successfully run `cap dev assets:download`
		And I successfully run `cap dev assets:cleanup`
		Then a remote file named "assets_path/download/file.html" should not exist
		And a remote file named "assets_path/download/subdirectory/file2.html" should not exist
		And a remote file named "assets_path/download/file3.html" should not exist
		When I successfully run `cap dev assets:update`
		And a remote file named "assets_path/download/file.html" should exist
		And a remote file named "assets_path/download/subdirectory/file2.html" should exist
		And a remote file named "assets_path/download/file3.html" should exist

	Scenario: Check if add_default_content is filling the remote server from the local preseeds
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev assets:cleanup`
		And I successfully run `cap dev assets:add_default_content`
		Then a remote file named "assets_path/download/file1.html" should exist
		And a remote file named "assets_path/download/subdirectory/file2.html" should exist
		And a remote file named "assets_path/download/test.png" should exist

	Scenario: Check if the exclude file is functioning
		Given the remote server is cleared
		And the project is deployed
		When I successfully run `cap dev assets:cleanup`
		Given a remote empty file named "assets_path/download/should_be_excluded.txt"
		Then a remote file named "assets_path/download/should_be_excluded.txt" should exist
		When I successfully run `cap dev assets:download`
		And I successfully run `cap dev assets:cleanup`
		Then a remote file named "assets_path/download/should_be_excluded.txt" should not exist
		When I successfully run `cap dev assets:update`
		Then a remote file named "assets_path/download/should_be_excluded.txt" should not exist
