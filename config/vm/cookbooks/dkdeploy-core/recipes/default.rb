# update apt packages
include_recipe 'apt'

# Create unix user for tests
user 'test-user' do
  action :create
end

group 'test-group' do
  action :create
  append true
  members 'test-user'
end

# install apache2-utils. It is needed for the assets:add_htpasswd task
package 'apache2-utils' do
  action :install
end

mysql_service 'default' do
  port '3306'
  bind_address '0.0.0.0' # Need for remote connection
  initial_root_password 'ilikerandompasswords'
  run_group 'vagrant'
  run_user 'vagrant'
  action [:create, :start]
end

mysql_config 'default' do
  instance 'default' # necessary in some cases, causes hanging on provisioning https://github.com/chef-cookbooks/mysql/issues/387
  owner 'vagrant' # use different user to allow capistrano access to log file
  group 'vagrant'
  source 'my_extra_settings.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end

mysql2_chef_gem 'default' do
  action :install
end

mysql_connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: 'ilikerandompasswords'
}

mysql_database 'dkdeploy_core' do
  connection mysql_connection_info
  action :create
end

mysql_database_user 'root' do
  connection mysql_connection_info
  host '%'
  password 'ilikerandompasswords'
  privileges [:all]
  action [:create, :grant]
end

directory '/var/www' do
  owner 'vagrant'
  group 'vagrant'
  mode '0770'
  action :create
end
