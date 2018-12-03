![dkdeploy](assets/dkdeploy-logo.png)

# dkdeploy::core

[![Build Status](https://travis-ci.org/dkdeploy/dkdeploy-core.svg?branch=develop)](https://travis-ci.org/dkdeploy/dkdeploy-core)
[![Gem Version](https://badge.fury.io/rb/dkdeploy-core.svg)](https://badge.fury.io/rb/dkdeploy-core) [![Inline docs](http://inch-ci.org/github/dkdeploy/dkdeploy-core.svg?branch=develop)](http://inch-ci.org/github/dkdeploy/dkdeploy-core)

## Description

This Rubygem `dkdeploy-core` represents the extension of [Capistrano](http://capistranorb.com/) tasks directed to advanced deployment processes.

## Installation

Add this line to your application's `Gemfile`

	gem 'dkdeploy-core', '~> 9.1'

and then execute

	bundle install

or install it yourself as

	gem install dkdeploy-core

## Usage

Run in your project root

	cap install STAGES='dev,integration,testing,production'

This command will create the following Capistrano file structure with all the standard pre-configured constants.
Please be aware of the difference to the [native installation](http://capistranorb.com/documentation/getting-started/preparing-your-application/) of Capistrano.
Certainly you have to adjust `config/deploy.rb` and respective stages and customize them for your needs.

<pre>
  ├── Capfile
  └── config
     ├── deploy
     │   ├── dev.rb
     │   ├── integration.rb
     │   ├── testing.rb
     │   └── production.rb
     └── deploy.rb
</pre>

As next you have to append the following line to the `Capfile` in order to make use of dkdeploy extensions in addition to the standard Capistrano tasks:

	require 'capistrano/dkdeploy/core'

To convince yourself, that Capistrano tasks list has been extended, please run

	cap -vT

Please note, that dkdeploy uses the local copy strategy and overwrites the `:scm` constant. If you want to use it,
you should do nothing more. However if you want to change it, for example to `:git`, please add the following line to `deploy.rb`

	set :scm, :git

For more information about available Capistrano constants please use the [Capistrano documentation](http://capistranorb.com/documentation/getting-started/preparing-your-application/).
The complete list of the dkdeploy constants you find in `/lib/capistrano/dkdeploy/core.rb`.

## Testing

### Prerequisite

rvm (v1.29.x) with installed Ruby 2.2.

Add the virtual box alias to your `hosts` file

	192.168.156.180 dkdeploy-core.test

### Running tests

1. Starting the local box (`vagrant up --provision`)
2. Checking coding styles (`rubocop`)
3. Running BDD cucumber tests (`cucumber`)

## Contributing

1. Install [git flow](https://github.com/nvie/gitflow)
2. Install [Homebrew](http://brew.sh/) and run `brew install mysql`
3. Install [NodeJS](https://nodejs.org) (supported: v0.12.7) via `brew install nodejs`
4. If project is not checked out already do git clone `git@github.com:dkdeploy/dkdeploy-core.git`
5. Checkout origin develop branch (`git checkout --track -b develop origin/develop`)
6. Git flow initialze `git flow init -d`
7. Installing gems `bundle install`
8. Create new feature branch (`git flow feature start my-new-feature`)
9. Run tests (README.md Testing)
10. Commit your changes (`git commit -am 'Add some feature'`)
