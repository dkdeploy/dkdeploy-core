Feature: Test tasks for error handlers

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And I extend the development capistrano configuration from the fixture file default_deployment_behaviour.rb
		And the project is deployed

	Scenario: When deployment fails before symlinking the new release
		Given I store the symlink source of current
		And I provoke an exception for testing purposes before symlinking the new release
		And a remote file named "shared_path/config/maintenance.json" should not exist
		Then I run `cap dev deploy`
		And the output should contain "Failing this deployment on purpose!"
		And the exit status should not be 0
		And a remote file named "shared_path/config/maintenance.json" should not exist
		And the symlink source of current should not have changed
		And the exit status should not be 0

	Scenario: When deployment fails after symlinking the new release
		Given I store the symlink source of current
		And I provoke an exception for testing purposes after symlinking the new release
		And a remote file named "shared_path/config/maintenance.json" should not exist
		Then I run `cap dev deploy`
		And the output should contain "Failing this deployment on purpose!"
		And the exit status should not be 0
		And a remote file named "shared_path/config/maintenance.json" should not exist
		And the symlink source of current should not have changed

	Scenario: Deployment rollback to last stable version on failure when failing before symlinking
		Given I successfully run `cap dev deploy`
 		And I successfully run `cap dev deploy`
 		And I successfully run `cap dev deploy`
		And I store the symlink source of current
		And I provoke an exception for testing purposes before symlinking the new release
		Then I run `cap dev deploy`
		And the output should contain "Failing this deployment on purpose!"
		And the exit status should not be 0
		And the symlink source of current should not have changed

	Scenario: Deployment rollback to last stable version on failure when failing after symlinking
		Given I successfully run `cap dev deploy`
 		And I successfully run `cap dev deploy`
 		And I successfully run `cap dev deploy`
		And I store the symlink source of current
		And I provoke an exception for testing purposes after symlinking the new release
		Then I run `cap dev deploy`
		And the output should contain "Failing this deployment on purpose!"
		And the exit status should not be 0
		And the symlink source of current should not have changed

	Scenario: Deployment do not execute project task at rollback behaviour
		Given I successfully run `cap dev deploy`
 		And I successfully run `cap dev deploy`
		And I provoke an exception for testing purposes before symlinking the new release
		And I extend the development capistrano configuration from the fixture file add_output_after_create_symlink.rb
		Then I run `cap dev deploy`
		And the output should not contain "Task 'deploy:symlink:release' executed"
		And the exit status should not be 0

	Scenario: Rollback execute all tasks
		Given I successfully run "cap dev deploy"
		And I provoke an exception for testing purposes after symlinking the new release
		And I extend the development capistrano configuration from the fixture file second_server.rb
		Then I run `cap dev deploy`
		And the output should not contain "Skipping task"
		And the exit status should not be 0
