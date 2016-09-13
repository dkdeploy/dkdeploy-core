# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dkdeploy/core/version'

Gem::Specification.new do |spec|
  spec.name          = 'dkdeploy-core'
  spec.version       = Dkdeploy::Core::Version
  spec.license       = 'MIT'
  spec.authors       = ['Lars Tode', 'Timo Webler', 'Kieran Hayes', 'Nicolai Reuschling', 'Johannes Goslar', 'Luka Lüdicke']
  spec.email         = %w(lars.tode@dkd.de timo.webler@dkd.de kieran.hayes@dkd.de nicolai.reuschling@dkd.de johannes.goslar@dkd.de luka.luedicke@dkd.de)
  spec.description   = 'dkd basic deployment tasks and strategies'
  spec.summary       = 'dkd basic deployment tasks and strategies'
  spec.homepage      = 'https://github.com/dkdeploy/dkdeploy-core'
  spec.required_ruby_version = '~> 2.1'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)\/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13.0'
  spec.add_development_dependency 'rake', '~> 11.2'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'cucumber', '~> 2.4'
  spec.add_development_dependency 'rubocop', '~> 0.42'
  spec.add_development_dependency 'aruba', '~> 0.14'
  spec.add_development_dependency 'mysql2', '~> 0.3'
  spec.add_development_dependency 'pry', '~> 0.10.3'
  spec.add_development_dependency 'dkdeploy-test_environment', '~> 1.0'

  spec.add_dependency 'capistrano', '~> 3.6.1'
  spec.add_dependency 'sshkit', '= 1.10.0'
  spec.add_dependency 'highline', '~> 1.7.1'
end
