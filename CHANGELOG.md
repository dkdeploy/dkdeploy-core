# Changelog
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [9.0.1]
### Summary

- use --no-tablespaces with mysqldump

## [9.0.0]
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

## [8.0.2] - 2020-08-21
### Summary

- use --no-tablespaces with mysqldump

## [8.0.1] - 2017-05-15
### Summary

- hotfix for GH25: erroneous Capistrano scope

## [8.0.0] - 2016-06-20
### Summary

- first public release

[Unreleased]: https://github.com/dkdeploy/dkdeploy-core/compare/master...develop
[9.0.1]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.0.1
[9.0.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v9.0.0
[8.0.2]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.2
[8.0.1]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.1
[8.0.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.0
