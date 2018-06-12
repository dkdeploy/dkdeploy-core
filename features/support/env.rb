require 'dkdeploy/test_environment/application'

ssh_config = {
  user: 'root',
  keys: [File.join(Dir.getwd, 'config', 'docker', 'ssh', 'vagrant')],
  port: '5001'
}

TEST_APPLICATION = Dkdeploy::TestEnvironment::Application.new(File.expand_path('../../../', __FILE__), 'localhost', ssh_config)
TEST_APPLICATION.mysql_connection_settings = { host: '127.0.0.1', port: 5002, username: 'root', password: 'ilikerandompasswords' }

# this configuration tricks Bundler into executing another Bundler project with clean enviroment
# The official way via Bundler.with_clean_env did not work properly here
Aruba.configure do |config|
  config.command_runtime_environment = { 'BUNDLE_GEMFILE' => File.join(TEST_APPLICATION.test_app_path, 'Gemfile') }
  config.exit_timeout = 30
end
