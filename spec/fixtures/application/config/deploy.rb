set :application, 'test_app'

SSHKit.config.command_map.prefix[:compass].push 'bundle exec'
SSHKit.config.command_map.prefix[:chown].push 'sudo'
SSHKit.config.command_map.prefix[:chgrp].push 'sudo'
SSHKit.config.command_map.prefix[:chmod].push 'sudo'

set :asset_folders, %w[fileadmin uploads]
set :asset_default_content, %w[fileadmin uploads]
set :asset_exclude_file, 'config/assets_exclude_file.txt'

set :format_options, command_output: true
set :log_level, :debug
set :format, :pretty

set :asset_default_content, %w[fileadmin uploads]
set :asset_exclude_file, 'config/assets_exclude_file.txt'
set :asset_folders, %w[fileadmin uploads]
