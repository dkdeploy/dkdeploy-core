Feature: Test tasks for namespace 'db'

	Background:
		Given a test app with the default configuration
		And the remote server is cleared
		And I want to use the database `dkdeploy_core`

	Scenario: Check if settings upload is possible with settings given as arguments
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		Then a remote file named "shared_path/config/db_settings.dev.yaml" should exist

	Scenario: Check if settings upload is possible with settings given interactively
		When I run `cap dev db:upload_settings` interactively
		And I type "database"
		And I type "3306"
		And I type "dkdeploy_core"
		And I type "root"
		And I type "ilikerandompasswords"
		And I type "utf8"
		And I close the stdin stream
		Then the exit status should be 0
		And a remote file named "shared_path/config/db_settings.dev.yaml" should exist

	Scenario: Check if settings upload is possible with settings given as enviroment variables
		When I successfully run `cap dev db:upload_settings DB_HOST=database DB_PORT=3306 DB_NAME=dkdeploy_core DB_USERNAME=root DB_PASSWORD=ilikerandompasswords DB_CHARSET=utf8`
		Then a remote file named "shared_path/config/db_settings.dev.yaml" should exist

	Scenario: Reading missing database config file
		When I run `cap dev db:read_db_settings`
		Then the output should contain "Unable to locate database config file on remote server."

	Scenario: Reading existing database config file
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		Then a file named "temp/db_settings.dev.yaml" should not exist
		When I run `cap dev db:read_db_settings`
		Then a file named "temp/db_settings.dev.yaml" should exist

	Scenario: Check if password will not appear in log
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		Then the output should not contain "ilikerandompasswords"

	Scenario: Check content of database after uploading a script
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		And I wait 5 seconds to let the database commit the transaction
		Then the database should have a table `demo_table` with column `demo_column`
		And the database should not have a table `wrong_table` with column `wrong_column`

	Scenario: Check dumping complete database without cache table content
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		And I successfully run `cap dev db:download`
		Then a file matching %r<database-dev-content.*sql.*gz> should exist
		And a file matching %r<database-dev-structure.*sql.*gz> should exist

	Scenario: Check dumping only structure of database
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		And I successfully run `cap dev db:download_structure`
		Then a file matching %r<database-dev-structure.*sql.*gz> should exist
		And a file matching %r<database-dev-content.*sql.*gz> should not exist

	Scenario: Check dumping content of database
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		And I successfully run `cap dev db:download_content`
		Then a file matching %r<database-dev-content.*sql.*gz> should exist
		And a file matching %r<database-dev-structure.*.sql.*gz> should not exist

	Scenario: Check dumping tables
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		When I successfully run `cap dev db:dump_table[demo_table]`
		Then a file matching %r<database-dev-demo_table.*sql.*gz> should exist

	Scenario: Check dumping tables to a specific file
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
		When I successfully run `cap dev db:download_tables[demo_table,temp,demo_table.sql]`
		Then a file matching %r<demo_table.*sql> should exist

	Scenario: Check database for preseed structure
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev db:add_default_structure`
		And I wait 5 second to let the database commit the transaction
		Then the database should have a table `preseed_table` with column `value`

	Scenario: Check database for preseed content
		When I successfully run `cap dev "db:upload_settings[database,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
		And I successfully run `cap dev db:add_default_structure`
		And I successfully run `cap dev db:add_default_content`
		And I wait 5 second to let the database commit the transaction
		Then the database should have a value `first preseed value` in table `preseed_table` for column `value`

	Scenario: Check error answer of a broken SQL syntax
		When I run `cap dev "db:sql_error"`
		Then the output should match /ERROR 1064/
