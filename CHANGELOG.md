# Changelog
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- tasks around MySQL slow log
- add `utils:create_local_temp_directory` task
- support for dkdeploy-test_environment v2.0.0
- Vagrant 2.0.x support
- rubocop upgrade to 0.50
- update capistrano to 3.8.0
- remove jenkins release suffix
- configuration option `additional_ignore_tables` changes from `string` to `array

### Fixed
- set group permissions for /var/www in Chef cookbook (Vagrant)
- set proper gem homepage
- add travis support
- improved code syntax according to RuboCop
- install `mysql` instead of `mysql-connector-c`
- remove sshkit dsl includes
- remove TYPO3 specific configuration

## [8.0.0] - 2016-06-20
### Summary

- first public release

[Unreleased]: https://github.com/dkdeploy/dkdeploy-core/compare/master...develop
[8.0.0]: https://github.com/dkdeploy/dkdeploy-core/releases/tag/v8.0.0
