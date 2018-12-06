Feature: Test tasks for namespace 'mysql'

  Background:
    Given a test app with the default configuration
    And the remote server is cleared
    And I want to use the database `dkdeploy_core`

  Scenario: Downloading the MYSQL slow log
    When I successfully run `cap dev "db:upload_settings[127.0.0.1,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
    And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
    And I successfully run `cap dev db:download_content`
    And I successfully run `cap dev mysql:download_slow_log`
    Then a file named "temp/slow-queries.dev.dkdeploy-core.test.log" should exist

  Scenario: Downloading the MYSQL slow log analyze file
    When I successfully run `cap dev "db:upload_settings[127.0.0.1,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
    And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
    And I successfully run `cap dev db:download_content`
    And I successfully run `cap dev mysql:analyze_download_slow_log`
    Then a file named "temp/mysql_slow_log_analyze.dev.dkdeploy-core.test.log" should exist

  Scenario: Clearing the MySQL slow log file
    When I successfully run `cap dev "db:upload_settings[127.0.0.1,3306,dkdeploy_core,root,ilikerandompasswords,utf8]"`
    And I successfully run `cap dev "db:update[temp,dkdeploy_core.sql.gz]"`
    And I successfully run `cap dev db:download_content`
    And I successfully run `cap dev mysql:clear_slow_log`
    Then the output should match /has been cleared/
