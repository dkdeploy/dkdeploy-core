set :application, 'test_app'

SSHKit.config.command_map.prefix[:compass].push 'bundle exec'

set :asset_folders, %w[download]
set :asset_default_content, %w[download]
set :asset_exclude_file, 'config/assets_exclude_file.txt'

set :format_options, command_output: true
set :log_level, :debug

set :asset_default_content, %w[download]
set :asset_exclude_file, 'config/assets_exclude_file.txt'
set :asset_folders, %w[download]

require 'dkdeploy/interaction_handler/mysql'
namespace :db do
  task :sql_error do
    remote_db_file_path = File.join(shared_path, 'config')
    remote_db_file = File.join(remote_db_file_path, 'broken.sql')
    username = 'test_user'
    password = "+p_secure[7Bvery_muchTL[E8yAGkMRT'A "
    now = Time.now.to_i
    sql_string = StringIO.new "INSERT INTO be_users (username, password, admin, tstamp, crdate)
                                VALUES ('#{username}', MD5('#{password}'), 1, #{now}, #{now});"
    on primary :backend do
      begin
        db_settings = {
          charset: 'utf8',
          username: 'root',
          password: 'ilikerandompasswords',
          host: 'database',
          port: 3306,
          name: 'dkdeploy_core'
        }
        execute :mkdir, '-p', remote_db_file_path
        execute :rm, '-rf', remote_db_file

        upload! sql_string, remote_db_file
        execute :mysql,
                "--default-character-set=#{db_settings.fetch(:charset)}",
                '-u', db_settings.fetch(:username),
                '-p',
                '-h', db_settings.fetch(:host), '-P', db_settings.fetch(:port), db_settings.fetch(:name),
                '-e', "'source #{remote_db_file}'",
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch(:password))
      ensure
        execute :rm, '-rf', remote_db_file
      end
    end
  end
end
