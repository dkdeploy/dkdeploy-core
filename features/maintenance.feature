Feature: Test tasks for namespace 'maintenance'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And the project is deployed

	Scenario: Check if maintenance.json is created on server if I run maintenance:enable
		When I successfully run `cap dev maintenance:enable`
		Then a remote file named "shared_path/config/maintenance.json" should exist

	Scenario: Check if maintenance.json is removed to the config directory if I run maintenance:disable
		When I successfully run `cap dev maintenance:enable`
		And I successfully run `cap dev maintenance:disable`
		Then a remote file named "shared_path/config/maintenance.json" should not exist

	Scenario: Check if maintenance.json is not removed on server if I run maintenance:disable in a permanent mode
		When I successfully run `cap dev maintenance:enable_permanent`
		And I successfully run `cap dev maintenance:disable`
		Then a remote file named "shared_path/config/maintenance.json" should exist

	Scenario: Check if maintenance.json is removed from the server if I run maintenance_disable_permanent in a permanent mode
		When I successfully run `cap dev maintenance:enable_permanent`
		And I successfully run `cap dev maintenance:disable_permanent`
		Then a remote file named "shared_path/config/maintenance.json" should not exist
