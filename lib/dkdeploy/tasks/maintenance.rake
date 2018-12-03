require 'json'
require 'i18n'
require 'dkdeploy/i18n'
require 'capistrano/dsl'

include Capistrano::DSL
include Dkdeploy::RollbackManager

namespace :maintenance do
  # Remote maintenance config file path
  #
  # @return [String]
  def maintenance_config_file_path
    File.join shared_path, 'config/maintenance.json'
  end

  desc 'Enables the maintenance mode. In a regular case it should be disabled after deployment.'
  task :enable do
    # Define rollback behaviour
    add_rollback_task 'maintenance:disable'

    on release_roles :app, :web do
      # create remote maintenance config file (and directory if not exists)
      execute :mkdir, '-p', File.dirname(maintenance_config_file_path)
      content_json = JSON.pretty_generate enabled_permanent: false
      # scp-net::upload! expects StringIO object
      content = StringIO.new content_json
      upload! content, maintenance_config_file_path
      info I18n.t('tasks.maintenance.enabled', mode: 'regular', scope: :dkdeploy)
    end
  end

  desc "Enables the maintenance permanent mode. The 'maintenance:disable' will require 'maintenance:disable_permanent'."
  task :enable_permanent do
    invoke 'maintenance:enable'
    on release_roles :app, :web do
      content_json = JSON.pretty_generate enabled_permanent: true
      # scp-net::upload! expects StringIO object
      content = StringIO.new content_json
      upload! content, maintenance_config_file_path
      info I18n.t('tasks.maintenance.enabled', mode: 'permanent', scope: :dkdeploy)
    end
  end

  desc "Disables the maintenance mode, if the 'maintenance:enabled_permanent' has not been enabled."
  task :disable do
    on release_roles :app, :web do
      # noinspection RubyArgCount
      if test %([ -f "#{maintenance_config_file_path}" ])
        if test "[ -s #{maintenance_config_file_path} ]"
          config_file_content = download! maintenance_config_file_path
          config_file_content = JSON.parse config_file_content
          if config_file_content.fetch 'enabled_permanent'
            warn I18n.t('tasks.maintenance.can_not_disable_by_reason_of_permanent', scope: :dkdeploy)
            next
          end
        end
        execute :rm, maintenance_config_file_path
      end
      info I18n.t('tasks.maintenance.disabled', mode: 'regular', scope: :dkdeploy)
    end
  end

  desc "Disables the maintenance permanent mode. The 'maintenance:disable' will work in a regular way again."
  task :disable_permanent do
    on release_roles :app, :web do
      execute :rm, maintenance_config_file_path
      info I18n.t('tasks.maintenance.disabled', mode: 'permanent', scope: :dkdeploy)
    end
  end
end
