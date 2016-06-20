Feature: Test tasks for namespace 'current_folder'

  Background:
    Given a test app with the default configuration
    And the remote server is cleared

  Scenario: Do not remove current folder if it is symlinked
    Given the project is deployed
    And I store the symlink source of current
    When I successfully run `cap dev current_folder:remove_unlesss_symlinked`
    Then the symlink source of current should not have changed

  Scenario: Remove current folder if it's not symlinked
    Given a remote directory named "current_path"
    When I successfully run `cap dev current_folder:remove_unlesss_symlinked`
    Then a remote directory named "current_path" should not exist

