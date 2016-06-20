Feature: Test tasks for namespace 'bower'

  Background:
    Given a test app with the default configuration

  Scenario: Given a bower.js file, running cap bower:run['install', 'htdocs'] results in Bower (v1.5.2) installing components
    When I successfully run `cap dev "bower:run[install,htdocs]"`
    Then the output should contain "bower jquery#2.1.4             install jquery#2.1.4"
    And a file named "htdocs/bower_components/jquery/dist/jquery.js" should exist

  Scenario: Running arbitrarily Bower commands
    Given I run `cap dev "bower:run[install,htdocs]"`
    When I run `cap dev "bower:run[list,htdocs]"`
    Then the output should contain "dkdeploy-core-bower-fixture-file#0.0.1"
    And the output should contain "└── jquery#2.1.4"
    When I successfully run `cap dev "bower:run[lookup bootstrap,htdocs]"`
    Then the output should contain "bootstrap https://github.com/twbs/bootstrap.git"

  Scenario: Running arbitrarily Bower commands with multiple bower.json files
    Given the default aruba exit timeout is 120 seconds
    And a file named "another_directory/bower.json" with:
    """
    {
      "name": "dkdeploy-core-another-bower-fixture-file",
      "version": "0.0.1",
      "authors": [
        "Random Coder <mail@example.com>"
      ],
      "description": "This is another fixture bower.js file for dkdeploy-core",
      "moduleType": [
        "globals"
      ],
      "license": "MIT",
      "dependencies": {
        "bootstrap": "3.3.5"
      }
    }
    """
    When I extend the development capistrano configuration variable bower_paths with value ['htdocs', 'another_directory']
    And I successfully run `cap dev "bower:run_all[install]"`
    Then a file named "htdocs/bower_components/jquery/dist/jquery.js" should exist
    And a file named "another_directory/bower_components/bootstrap/dist/css/bootstrap.css" should exist

  Scenario: Running a Bower command with missing bower.json file
    Given I successfully run `rm htdocs/bower.json`
    When I successfully run `cap dev "bower:run[install,htdocs]"`
    Then the output should contain "Skipping directory htdocs because it does not contain a bower.json file."

  Scenario: Running a Bower command with missing directory configured
    Given I successfully run `rm htdocs/bower.json`
    When I successfully run `cap dev "bower:run[install,i_do_not_exist]"`
    Then the output should contain "Skipping directory i_do_not_exist because it does not exist."
