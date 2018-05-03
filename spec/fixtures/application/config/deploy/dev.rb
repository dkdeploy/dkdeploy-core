set :deploy_to, '/var/www/dkdeploy'
server 'dkdeploy-core.test', roles: %w[web app backend db], primary: true

# no ssh compression on the dev stage
set :ssh_options, {
  compression: 'none'
}

ssh_key_files = Dir.glob(File.join(Dir.getwd, '..', '..', '.vagrant', 'machines', '**', 'virtualbox', 'private_key'))
unless ssh_key_files.empty?
  # Define generated ssh key files
  set :ssh_options, fetch(:ssh_options).merge(
    {
      user: 'vagrant',
      keys: ssh_key_files
    }
  )
end

set :copy_source, 'htdocs'
set :copy_exclude, %w[
  Gemfile*
  .hidden
  **/.hidden
]

# version file path
set :version_file_path, ''

# default file owner/group for dev stage
set :default_file_access_owner_of_shared_path, 'vagrant'
set :default_file_access_owner_of_release_path, 'vagrant'

set :default_file_access_group_of_shared_path, 'vagrant'
set :default_file_access_group_of_release_path, 'vagrant'

# mysql slow query log for performance analysis
set :mysql_slow_log, '/var/log/mysql-default/slow-queries.log'
