Feature: Test tasks for namespace 'deploy'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared

	Scenario: Check if the main capistrano directory structure has been created
		When I successfully run `cap dev deploy`
		Then a remote directory named "deploy_path/releases" should exist
		Then a remote directory named "deploy_path/shared" should exist

	Scenario: Check if the main capistrano symlink structure has been created
		When I successfully run `cap dev deploy`
		Then a remote symlink named "deploy_path/current" should exist

	Scenario: Check if the complete directory structure has been successfully deployed
		When I successfully run `cap dev deploy`
		Then a remote directory named "current_path/catalog" should exist

	Scenario: Check if the complete file structure has been successfully deployed
		When I successfully run `cap dev deploy`
		Then a remote file named "current_path/index.html" should exist

	Scenario: Check if the not wanted files have been excluded
		When I successfully run `cap dev deploy`
		Then a remote file named "current_path/Gemfile" should not exist
		Then a remote file named "current_path/Gemfile.lock" should not exist

	Scenario: Check if the not wanted directories have been excluded
		When I successfully run `cap dev deploy`
		Then a remote directory named "current_path/.hidden" should not exist
		Then a remote directory named "current_path/catalog/.hidden" should not exist
		Then a remote directory named "test_app/tmp_path" should not exist

	Scenario Outline: Check if I can deploy a project with different root sources
		When I extend the development capistrano configuration variable copy_source with value <configuration_value>
		And I successfully run `cap dev deploy`
		Then a remote directory named "<remote_directory>/<target_path>" should exist

		Examples:
			| configuration_value | target_path | remote_directory |
			| '.'                 | htdocs      | current_path     |
			| 'htdocs'            | catalog     | current_path     |

	Scenario: Test default deployment behaviour
		Given I extend the development capistrano configuration from the fixture file default_deployment_behaviour.rb
		And I run `cap dev deploy`
		Then the exit status should be 0
