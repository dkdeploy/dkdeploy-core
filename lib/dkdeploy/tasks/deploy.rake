require 'dkdeploy/dsl'

include Capistrano::DSL
include Dkdeploy::DSL
include Dkdeploy::RollbackManager

namespace :deploy do
  desc 'Generate the new release path name'
  task :new_release_path do
    jenkins_suffix = ''
    # Add jenkins build name and number to release path
    if ENV['BUILD_TAG']
      jenkins_suffix = "-#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}"
    end
    set_release_path releases_path.join(Time.now.utc.strftime('%Y-%m-%d-%H-%M-%S') + jenkins_suffix)
  end

  desc 'Handle deployment errors'
  task :failed do
    # Rollback tasks. Reverse sorting for rollback
    tasks_for_rollback = rollback_tasks.reverse

    run_locally do
      error I18n.t('error_during_deployment', scope: :dkdeploy)
    end

    # Check if symlink is created at host
    on release_roles(:all) do |host|
      if test "[ `readlink #{current_path}` == #{release_path} ]"
        invoke_for_server host, 'deploy:revert_release'
        invoke_for_server host, 'deploy:symlink:release'
      end
    end
    # Backup and remove last release
    invoke 'deploy:cleanup_rollback'

    run_locally do
      error I18n.t('rollback_tasks', tasks_for_rollback: tasks_for_rollback.join(', '), scope: :dkdeploy) unless tasks_for_rollback.empty?
    end

    # Call rollback task after reset release
    tasks_for_rollback.each do |task_name|
      next unless Rake::Task.task_defined? task_name

      # call rollback task
      Rake::Task[task_name].reenable
      invoke task_name
    end

    run_locally do
      error I18n.t('rollback_finished', scope: :dkdeploy)
    end
  end

  desc 'Remove and archive rolled-back release'
  task :cleanup_rollback do
    # Only keep x rolled-back releases as archive
    on release_roles(:all) do
      begin
        rollback_archives = capture(:ls, '-x', deploy_path.join('rolled-back-release-*.tar.gz')).split
      rescue SSHKit::StandardError
        rollback_archives = []
      end

      next if rollback_archives.count <= fetch(:keep_rollback_archives)
      info I18n.t('keep_rollback_archives',
                  scope: :dkdeploy,
                  host: host.to_s,
                  keep_rollback_archives: fetch(:keep_rollback_archives),
                  rollback_archives: rollback_archives.count)

      list_of_deleteable_directories = rollback_archives - rollback_archives.last(fetch(:keep_rollback_archives))
      string_of_deleteable_directories = list_of_deleteable_directories.map { |rollback_archive| current_path.join(rollback_archive) }.join(' ')
      execute :rm, '-rf', string_of_deleteable_directories
    end
  end
end
