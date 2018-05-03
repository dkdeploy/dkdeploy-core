require 'dkdeploy/constants'
require 'dkdeploy/helpers/common'
require 'dkdeploy/helpers/db'
require 'dkdeploy/interaction_handler/mysql'
require 'digest/md5'
require 'yaml'

include Dkdeploy::Constants
include Dkdeploy::Helpers::Common
include Dkdeploy::Helpers::DB
include Capistrano::DSL

namespace :db do
  task read_db_settings: 'utils:create_local_temp_directory' do
    on release_roles :app do
      unless test("[ -f #{remote_database_config_path} ]")
        error I18n.t('errors.database_config_file_missing', scope: :dkdeploy)
        exit 1
      end

      set :db_settings, read_db_settings_for_context(self)
      set :db_host,     fetch(:db_settings).fetch('host')
      set :db_port,     fetch(:db_settings).fetch('port')
      set :db_name,     fetch(:db_settings).fetch('name')
      set :db_username, fetch(:db_settings).fetch('username')
      set :db_password, fetch(:db_settings).fetch('password')
      set :db_charset,  fetch(:db_settings).fetch('charset')
    end

    File.write local_database_config_path, db_settings_hash.to_yaml
  end

  desc 'Upload database settings file'
  task :upload_settings, :db_host, :db_port, :db_name, :db_username, :db_password, :db_charset do |_, args|
    set :db_host,     ask_variable(args, :db_host, 'questions.database.host') { |question| question.default = '127.0.0.1' }
    set :db_port,     ask_variable(args, :db_port, 'questions.database.port') { |question| question.default = '3306' }
    set :db_name,     ask_variable(args, :db_name, 'questions.database.name') { |question| question.default = [fetch(:application), fetch(:stage)].join('_').tr('-', '_') }
    set :db_username, ask_variable(args, :db_username, 'questions.database.username') { |question| question.default = 'root' }
    set :db_password, ask_variable(args, :db_password, 'questions.database.password') { |question| question.echo    = '*' }
    set :db_charset,  ask_variable(args, :db_charset, 'questions.database.charset') { |question| question.default = 'utf8' }

    if fetch(:db_password).empty?
      run_locally do
        error I18n.t('errors.password_was_empty', scope: :dkdeploy)
        exit 1
      end
    end

    on release_roles :app do
      begin
        execute :mysql,
                '-u', fetch(:db_username),
                '-p', '-h', fetch(:db_host), '-P', fetch(:db_port), '-e', 'exit',
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(fetch(:db_password))
      rescue SSHKit::Command::Failed
        error I18n.t('errors.connection_failed', scope: :dkdeploy)
        exit 1
      end
      execute :mkdir, '-p', File.join(shared_path, 'config')
      execute :rm, '-f', remote_database_config_path
      upload! StringIO.new(db_settings_hash.to_yaml), remote_database_config_path
      info I18n.t('success.settings_uploaded', scope: :dkdeploy)
    end
  end

  desc 'Upload, unzip and execute database script'
  task :update, :file_path, :zipped_db_file do |_, args|
    file_path      = ask_variable(args, :file_path, 'questions.path') { |question| question.default = 'temp' }
    zipped_db_file = ask_variable(args, :zipped_db_file, 'questions.database.zipped_db_file') { |question| question.default = 'database.sql.gz' }

    local_zipped_file_name = File.join(file_path, zipped_db_file)
    remote_zipped_file_name = File.join(fetch(:deploy_to), zipped_db_file)
    remote_file_name = File.join(fetch(:deploy_to), zipped_db_file.slice(0..-4)) # we assume file name ending .sql.gz

    unless File.exist?(local_zipped_file_name)
      run_locally do
        error I18n.t('errors.file_not_found', scope: :dkdeploy)
        exit 1
      end
    end

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_zipped_file_name
        execute :rm, '-f', remote_file_name
        upload! local_zipped_file_name, remote_zipped_file_name, via: :scp
        execute :gunzip, remote_zipped_file_name
        execute :mysql,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'),
                '-e', "'source #{remote_file_name}'",
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
      ensure
        execute :rm, '-f', remote_zipped_file_name
        execute :rm, '-f', remote_file_name
      end
    end
  end

  desc 'Dump complete database without cache table content to local temp folder'
  task download: %i[download_structure download_content]

  desc 'Dumps complete database structure without content'
  task download_structure: 'utils:create_local_temp_directory' do
    dump_file = db_dump_file_structure
    remote_dump_file = File.join(fetch(:deploy_to), dump_file)
    remote_zipped_dump_file = "#{remote_dump_file}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file
        execute :mysqldump,
                '--no-data', '--skip-set-charset',
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'),
                '>', remote_dump_file,
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
        execute :gzip, remote_dump_file
        download! remote_zipped_dump_file, 'temp', via: :scp
      ensure
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file
      end
    end
  end

  desc 'Dump complete database content without cache tables and structure to local temp folder'
  task download_content: 'utils:create_local_temp_directory' do
    dump_file = db_dump_file_content
    remote_dump_file = File.join(fetch(:deploy_to), dump_file)
    remote_zipped_dump_file = "#{remote_dump_file}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file

        ignore_tables_command_line = ignore_tables.inject('') do |command_line, table|
          command_line << " --ignore-table=#{db_settings.fetch('name')}.#{table}"
        end

        execute :mysqldump,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '--skip-set-charset',
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), ignore_tables_command_line, db_settings.fetch('name'),
                '>', remote_dump_file,
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
        execute :gzip, remote_dump_file
        download! remote_zipped_dump_file, 'temp', via: :scp
      ensure
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file
      end
    end
  end

  desc 'Dump content of a database table to local temp folder'
  task :dump_table, [:table_name] => ['utils:create_local_temp_directory'] do |_, args|
    table_name = ask_variable(args, :table_name, 'questions.database.table_name')

    dump_file = db_dump_file table_name
    zipped_dump_file = File.join('temp', "#{dump_file}.gz")
    remote_dump_file = File.join(deploy_to, dump_file)
    remote_zipped_dump_file = "#{remote_dump_file}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file
        execute :mysqldump,
                '--no-data', '--skip-set-charset',
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'), table_name,
                '>', remote_dump_file,
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
        execute :gzip, remote_dump_file
        download! remote_zipped_dump_file, zipped_dump_file, via: :scp
      ensure
        execute :rm, '-f', remote_dump_file
        execute :rm, '-f', remote_zipped_dump_file
      end
    end
  end

  desc 'Dump content of a list of database tables to a local folder'
  task :dump_tables, :table_names, :file_path, :file_name do |_, args|
    table_names = ask_array_variable(args, :table_names, 'questions.database.table_names')
    file_path   = ask_variable(args, :file_path, 'questions.path') { |question| question.default = 'temp' }
    file_name   = ask_variable(args, :file_name, 'questions.file_name') { |question| question.default = [fetch(:application), fetch(:stage), table_names].join('_') }

    local_file_name = File.join(file_path, file_name)
    local_zipped_file = "#{local_file_name}.gz"
    remote_file_name = File.join(fetch(:deploy_to), file_name)
    remote_zipped_file = "#{remote_file_name}.gz"

    FileUtils.mkdir_p file_path

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_file_name
        execute :rm, '-f', remote_zipped_file
        execute :mysqldump,
                '--no-data', '--skip-set-charset',
                '--no-create-info', '--skip-comments',
                '--skip-extended-insert', '--skip-set-charset',
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'),
                db_settings.fetch('name'), table_names.join(' '),
                '>', remote_file_name,
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
        execute :gzip, remote_file_name
        download! remote_zipped_file, local_zipped_file, via: :scp
      ensure
        execute :rm, '-f', remote_file_name
        execute :rm, '-f', remote_zipped_file
      end
    end

    run_locally do
      execute :gunzip, local_zipped_file
    end
  end

  desc 'Add default content from config/preseed/default_content.sql.gz to database'
  task :add_default_content do
    local_zipped_default_content_file = File.join('config', 'preseed', 'default_content.sql.gz')
    remote_default_content_file = File.join(fetch(:deploy_to), 'default_content.sql')
    remote_zipped_default_content_file = "#{remote_default_content_file}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_default_content_file
        execute :rm, '-f', remote_zipped_default_content_file
        upload! local_zipped_default_content_file, remote_zipped_default_content_file, via: :scp
        execute :gunzip, remote_zipped_default_content_file
        execute :mysql,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'),
                '-e', "'source #{remote_default_content_file}'",
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
      ensure
        execute :rm, '-f', remote_default_content_file
        execute :rm, '-f', remote_zipped_default_content_file
      end
    end
  end

  desc 'Add structure content from config/preseed/default_structure.sql.gz to database'
  task :add_default_structure do
    local_zipped_default_structure_file = File.join('config', 'preseed', 'default_structure.sql.gz')
    remote_default_structure_file = File.join(fetch(:deploy_to), 'default_structure.sql')
    remote_zipped_default_structure_file = "#{remote_default_structure_file}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_default_structure_file
        execute :rm, '-f', remote_zipped_default_structure_file
        upload! local_zipped_default_structure_file, remote_zipped_default_structure_file, via: :scp
        execute :gunzip, remote_zipped_default_structure_file
        execute :mysql,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'), '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'),
                '-e', "'source #{remote_default_structure_file}'",
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
      ensure
        execute :rm, '-f', remote_default_structure_file
        execute :rm, '-f', remote_zipped_default_structure_file
      end
    end
  end

  desc 'Download database tables'
  task :download_tables, :table_names, :file_path, :file_name do |_, args|
    table_names = ask_array_variable(args, :table_names, 'questions.database.table_names')
    file_path   = ask_variable(args, :file_path, 'questions.path') { |question| question.default = 'temp' }
    file_name   = ask_variable(args, :file_name, 'questions.file_name') { |question| question.default = [fetch(:application), fetch(:stage), table_names].join('_') }
    table_names = table_names.join(' ')

    FileUtils.mkdir_p file_path

    remote_file_name = File.join(fetch(:deploy_to), file_name)
    remote_zipped_file = "#{remote_file_name}.gz"
    local_file_name = File.join(file_path, file_name)
    local_zipped_file = "#{local_file_name}.gz"

    on primary :backend do
      begin
        db_settings = read_db_settings_for_context(self)
        execute :rm, '-f', remote_file_name
        execute :rm, '-f', remote_zipped_file
        execute :mysqldump,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '--no-create-info', '--skip-comments',
                '--skip-extended-insert', '--skip-set-charset',
                '--complete-insert',
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'),
                db_settings.fetch('name'), table_names,
                '>', remote_file_name,
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
        execute :gzip, remote_file_name
        download! remote_zipped_file, local_zipped_file, via: :scp
      ensure
        execute :rm, '-f', remote_file_name
        execute :rm, '-f', remote_zipped_file
      end
    end

    run_locally do
      execute :rm, '-f', local_file_name # Delete local file, before unzip
      execute :gunzip, local_zipped_file
    end

    sql = File.read(local_file_name)
    File.open(local_file_name, 'w') do |io|
      table_names.split(' ').each do |table|
        io.write("TRUNCATE TABLE #{table};\n")
      end
      io.write(sql)
    end
  end

  desc 'Update database tables'
  task :upload_tables, :file_path, :file_name do |task, args|
    file_path = ask_variable(args, :file_path, 'questions.path') { |question| question.default = 'temp' }
    file_name = ask_variable(args, :file_name, 'questions.file_name') { |question| question.default = [fetch(:application), fetch(:stage)].join('_') }

    sql_dump_file = File.join(file_path, file_name)
    remote_db_path = File.join(shared_path, '/db')
    remote_dump_file = File.join(remote_db_path, file_name)
    remote_dump_md5_file = File.join("#{remote_dump_file}.md5")
    local_md5 = Digest::MD5.file(sql_dump_file).hexdigest

    on primary :backend do
      execute :mkdir, '-p', remote_db_path
    end

    run_locally do
      info I18n.t('info.local_md5', md5_hash: local_md5, scope: :dkdeploy)
    end

    remote_md5 = '' # to allow assignment in block and later comparison
    on primary :backend do
      remote_md5 = capture("cat #{remote_dump_md5_file}") if test("[ -f #{remote_dump_md5_file} ]")
    end

    run_locally do
      info I18n.t('info.remote_md5', md5_hash: remote_md5, scope: :dkdeploy)
    end

    if local_md5 == remote_md5
      run_locally do
        info I18n.t('info.md5_match', scope: :dkdeploy)
      end
      next
    end

    begin
      on primary :backend do
        db_settings = read_db_settings_for_context(self)
        upload! StringIO.new(local_md5), remote_dump_md5_file
        upload! sql_dump_file, remote_dump_file
        execute :mysql,
                "--default-character-set=#{db_settings.fetch('charset')}",
                '-u', db_settings.fetch('username'),
                '-p',
                '-h', db_settings.fetch('host'), '-P', db_settings.fetch('port'), db_settings.fetch('name'),
                '-e', "'source #{remote_dump_file}'",
                interaction_handler: Dkdeploy::InteractionHandler::MySql.new(db_settings.fetch('password'))
      end
    rescue SSHKit::Command::Failed => exception
      run_locally do
        error "Removing #{remote_dump_file} and #{remote_dump_md5_file}"
        execute :rm, '-f', remote_dump_md5_file
        execute :rm, '-f', remote_dump_file
      end
      task.reenable
      raise "upload_tables failed: #{exception.message}"
    end
  end
end
