set :deploy_to, '/var/www/dkdeploy'
server 'root@localhost:5001', roles: %w[web app backend db], primary: true

# no ssh compression on the dev stage
set :ssh_options, {
  compression: 'none',
  keys: [File.join(Dir.getwd, '..', '..', 'config', 'docker', 'ssh', 'vagrant')]
}

set :copy_source, 'htdocs'
set :copy_exclude, %w[
  Gemfile*
  .hidden
  **/.hidden
]

# version file path
set :version_file_path, ''

# default file owner/group for dev stage
set :default_file_access_owner_of_shared_path, 'root'
set :default_file_access_owner_of_release_path, 'root'

set :default_file_access_group_of_shared_path, 'root'
set :default_file_access_group_of_release_path, 'root'

# mysql slow query log for performance analysis
set :mysql_slow_log, '/var/log/mysql/slow-queries.log'
