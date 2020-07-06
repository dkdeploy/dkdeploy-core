# Changelog
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [9.3.0] - 2020-07-06
### Summary

- Update gem `capistrano` to 3.14.x
- Update gem `highline` to 2.0.x
- Update gem 'aruba' to 1.0.x
- Test ruby 2.7 via travis
- Requires Ruby v2.5 or later

## [9.2.3] - 2019-05-29
### Summary

- Remove frozen string error
- Update interaction handler for new `htpasswd` versions
- Use correct test statement for task "remove_unless_symlinked"

## [9.2.2] - 2019-02-18
### Summary

- run tests and linter against Ruby 2.3
- fixed bug in clean_up_temporary_sources 

## [9.2.1] - 2019-12-06
### Summary

- removed loading of pry

## [9.2.0] - 2019-12-06 [YANKED]
### Summary

- supports Ruby 2.5
- removes Bower support
- moved test infrastructure to Ubuntu Xenial
- we no longer remove maintenance_config_file_path forcefully to make failures more apparent
- improved shell independence

## [9.1.0] - 2018-02-09
### Summary

- Use correct capistrano context at copy scm
- Update capistrano 3.10.1
- Always execute tasks for each server or at rollback

## [9.0.0] 2017-10-16
### Summary

- tasks around MySQL slow log
- add `utils:create_local_temp_directory` task
- support for dkdeploy-test_environment v2.0.0
- Vagrant 2.0.x support
- rubocop upgrade to 0.50
- update capistrano to v3.9.0
- remove jenkins release suffix
- configuration option `additional_ignore_tables` changes from `string` to `array`
- set group permissions for `/var/www` in Chef cookbook (Vagrant)
- set proper gem homepage
- add travis support
- improved code syntax according to RuboCop
- install `mysql` instead of `mysql-connector-c`
- remove sshkit dsl includes
- remove TYPO3 specific configuration
- change some SCM roles from app to all

## [8.0.1] - 2017-05-15
### Summary

- hotfix for GH25: erroneous Capistrano scope

## [8.0.0] - 2016-06-20
### Summary

- first public release

[Unreleased]: https://github.com/dkdeploy/dkdeploy-core/compare/master...develop
[9.2.2]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.2.2
[9.2.1]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.2.1
[9.2.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.2.0
[9.1.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.1.0
[9.0.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.0.0
[8.0.1]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.1
[8.0.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.0
