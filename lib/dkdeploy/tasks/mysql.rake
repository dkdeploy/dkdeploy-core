require 'dkdeploy/constants'
require 'dkdeploy/helpers/common'
require 'dkdeploy/helpers/mysql'

include Dkdeploy::Constants
include Dkdeploy::Helpers::Common
include Dkdeploy::Helpers::MySQL
include Capistrano::DSL

namespace :mysql do
  desc 'Clear slow log file'
  task :clear_slow_log do
    mysql_slow_log = fetch(:mysql_slow_log, '')
    on roles :db do |server|
      next unless slow_log_exists? mysql_slow_log

      execute :echo, '', '>', mysql_slow_log
      info I18n.t('tasks.mysql.clear_slow_log', file: mysql_slow_log, host: server, scope: :dkdeploy)
    end
  end

  desc 'Download slow log file to temp/'
  task download_slow_log: 'utils:create_local_temp_directory' do
    mysql_slow_log = fetch(:mysql_slow_log, '')
    on roles :db do |server|
      next unless slow_log_exists? mysql_slow_log

      local_filename = File.join(local_dump_path, "#{File.basename(mysql_slow_log, '.*')}.#{fetch(:stage)}.#{server.hostname}#{File.extname(mysql_slow_log)}")
      info I18n.t('file.download', file: mysql_slow_log, target: local_filename, host: server)
      download! mysql_slow_log, local_filename, via: :scp
    end
  end

  desc 'Download slow log file to temp'
  task analyze_download_slow_log: 'utils:create_local_temp_directory' do
    mysql_slow_log = fetch(:mysql_slow_log, '')
    on roles :db do |server|
      next unless slow_log_exists? mysql_slow_log

      analyze_filename = "mysql_slow_log_analyze.#{fetch(:stage)}.#{server.hostname}.log"
      remote_filename = File.join(deploy_path, analyze_filename)
      local_filename = File.join(local_dump_path, analyze_filename)
      # delete file, if exist
      execute :rm, '-f', remote_filename
      info I18n.t('tasks.mysql.analyze_slow_log', host: server, scope: :dkdeploy)
      execute :mysqldumpslow, '-s', 't', mysql_slow_log, '>', remote_filename
      info I18n.t('file.download', file: remote_filename, target: local_filename, host: server)
      download! remote_filename, local_filename, via: :scp
      # delete file, if exist
      execute :rm, '-f', remote_filename
    end
  end
end
