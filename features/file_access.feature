Feature: Test tasks for namespace 'file_permissions'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And the project is deployed
		And I extend the development capistrano configuration from the fixture file custom_file_access.rb

  # owner/group of shared path
	Scenario: Check if the default owner and group of shared path are set correctly
		Given I extend the development capistrano configuration variable default_file_access_owner_of_shared_path with value 'test-user'
		And I extend the development capistrano configuration variable default_file_access_group_of_shared_path with value 'test-group'
		And I successfully run `cap dev file_access:set_owner_group_of_shared_path`
		Then remote owner of "shared_path" should be "test-user"
		And remote group of "shared_path" should be "test-group"

  # owner/group of release path
	Scenario: Check if the default owner and group of release path are set correctly
		Given I extend the development capistrano configuration variable default_file_access_owner_of_release_path with value 'test-user'
		And I extend the development capistrano configuration variable default_file_access_group_of_release_path with value 'test-group'
		And I successfully run `cap dev file_access:set_owner_group_of_release_path`
		Then remote owner of "deploy_path/current" should be "test-user"
		And remote owner of "current_path/index.html" should be "test-user"
		And remote owner of "current_path/catalog" should be "test-user"
		And remote group of "deploy_path/current" should be "test-group"
		And remote group of "current_path/index.html" should be "test-group"
		And remote group of "current_path/catalog" should be "test-group"

  # file permission of shared path
	Scenario: Check if the default file access properties on shared contain the following permissions
		Given I extend the development capistrano configuration from the fixture file custom_file_access.rb
		And I successfully run `cap dev file_access:set_permissions`
		Then remote permissions of "shared_path" should contain "user" "read"
		And remote permissions of "shared_path" should contain "user" "write"
		And remote permissions of "shared_path" should contain "user" "execute"
		And remote permissions of "shared_path" should contain "group" "read"
		And remote permissions of "shared_path" should contain "group" "execute"

  # file permission of release path
	Scenario: Check if the default file access properties on release contain the following permissions
		Given I extend the development capistrano configuration from the fixture file custom_file_access.rb
		And I successfully run `cap dev file_access:set_permissions`
		Then remote permissions of "current_path/index.html" should contain "user" "read"
		And remote permissions of "current_path/index.html" should contain "user" "write"
		And remote permissions of "current_path/catalog" should contain "user" "execute"
		And remote permissions of "current_path/index.html" should contain "group" "read"
		And remote permissions of "current_path/catalog" should contain "group" "execute"

	Scenario: Check if the default file access properties on release does not contain the following permissions
		Given I extend the development capistrano configuration from the fixture file custom_file_access.rb
		And I successfully run `cap dev file_access:set_permissions`
		Then remote permissions of "current_path/index.html" should not contain "user" "execute"
		And remote permissions of "current_path/index.html" should not contain "group" "write"
		And remote permissions of "current_path/index.html" should not contain "group" "execute"
		And remote permissions of "current_path/index.html" should not contain "others" "read"
		And remote permissions of "current_path/index.html" should not contain "others" "write"

	Scenario: Check if the default file access properties on shared does not contain the following permissions
		Given I extend the development capistrano configuration from the fixture file custom_file_access.rb
		And I successfully run `cap dev file_access:set_permissions`
		Then remote permissions of "shared_path" should not contain "group" "write"
		And remote permissions of "shared_path" should not contain "others" "read"
		And remote permissions of "shared_path" should not contain "others" "write"
		And remote permissions of "shared_path" should not contain "others" "execute"

	Scenario: Check if the custom file owner and group are set correctly
		When I successfully run `cap dev file_access:set_custom_access`
		Then remote owner of "current_path/catalog" should be "test-user"
		And remote group of "current_path/catalog" should be "test-group"

	Scenario: Check if the custom file access properties on release contain the following permissions
		When I successfully run `cap dev file_access:set_custom_access`
		Then remote permissions of "current_path/catalog" should contain "user" "read"
		And remote permissions of "current_path/catalog" should contain "user" "write"
		And remote permissions of "current_path/catalog" should contain "user" "execute"
		And remote permissions of "current_path/catalog" should contain "group" "read"
		And remote permissions of "current_path/catalog" should contain "group" "write"
		And remote permissions of "current_path/catalog" should contain "group" "execute"
		And remote permissions of "current_path/catalog" should contain "others" "read"

	Scenario: Check if the custom file access properties on release does not contain the following permissions
		When I successfully run `cap dev file_access:set_custom_access`
		Then remote permissions of "current_path/catalog" should not contain "others" "write"
		And remote permissions of "current_path/catalog" should not contain "others" "execute"

	Scenario: Check if the set_custom_access task skips over not existing folders
		Given I extend the development capistrano configuration variable custom_file_access with value {app: {release_path: {catalog: {mode: 'u+rwx,g+rwx,o-wx'}, not_existing: {mode: 'u+rwx,g+rwx,o-wx'}}}}
		And a remote directory named "releases_path/not_existing" should not exist
		When I successfully run `cap dev file_access:set_custom_access`
		Then the output should contain "The resource /var/www/dkdeploy/current/not_existing does not exist on host dkdeploy-core.test"
		And the output should not contain "sudo chmod  u+rwx,g+rwx,o-wx /var/www/dkdeploy/current/not_existing"
		And the output should contain "sudo chmod  u+rwx,g+rwx,o-wx /var/www/dkdeploy/current/catalog"

	Scenario: Check if the selected_custom file_access_task skips with empty selected_custom_file_access
		Given I extend the development capistrano configuration variable default_file_access_owner_of_shared_path with value 'test-user'
		When I run `cap dev file_access:set_selected_custom_access`
		Then the exit status should be 1
		And the output should contain "The variable 'selected_custom_file_access' is empty. Aborting task..."

	Scenario: Check if the selected_custom_file_access_task runs with configured selected_custom_file_access
		Given I extend the development capistrano configuration variable default_file_access_owner_of_shared_path with value 'test-user'
		And I extend the development capistrano configuration variable selected_custom_file_access with value [:catalog]
		When I successfully run `cap dev file_access:set_selected_custom_access`
		Then the output should contain "sudo chown -R test-user /var/www/dkdeploy/current/catalog"

	Scenario: Check if the selected_custom_file_access task skips over not mentioned folders
		Given I extend the development capistrano configuration variable default_file_access_owner_of_shared_path with value 'test-user'
		And I extend the development capistrano configuration variable selected_custom_file_access with value ['another_directory']
		When I successfully run `cap dev file_access:set_selected_custom_access`
		Then the output should contain "Skipped setting custom_file_access permissions for 'catalog' because it is not mentioned in selected_custom_file_access!"
		And the output should not contain "sudo chown -R test-user /var/www/dkdeploy/current/catalog"

	Scenario: Check if the selected_custom_file_access task skips over not existing folders
		Given I extend the development capistrano configuration variable custom_file_access with value {app: {release_path: {catalog: {mode: 'u+rwx,g+rwx,o-wx'}, not_existing: {mode: 'u+rwx,g+rwx,o-wx'}}}}
		And I extend the development capistrano configuration variable selected_custom_file_access with value [:not_existing, :catalog]
		And a remote directory named "releases_path/not_existing" should not exist
		When I successfully run `cap dev file_access:set_selected_custom_access`
		Then the output should contain "The resource /var/www/dkdeploy/current/not_existing does not exist on host dkdeploy-core.test"
		And the output should not contain "sudo chmod -R u+rwx,g+rwx,o-wx /var/www/dkdeploy/current/not_existing"
		And the output should contain "sudo chmod -R u+rwx,g+rwx,o-wx /var/www/dkdeploy/current/catalog"
