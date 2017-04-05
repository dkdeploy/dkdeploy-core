# This trick lets us access the copy plugin within `on` blocks.
copy_plugin = self

namespace :copy do
  desc 'Check if all configuration variables and copy sources exist'
  task :check do
    run_locally do
      unless Dir.exist? copy_source
        fatal I18n.t('directory.not_exists', name: copy_source, scope: :dkdeploy)
        exit 1
      end
    end
  end

  desc 'Upload the source repository to releases'
  task create_release: %i[build_source_archive copy_archive_to_server clean_up_temporary_sources]

  # Builds a tar archive in a temporary directory
  # excluding files and folders matching the configured pattern.
  #
  task :build_source_archive do
    run_locally do
      info I18n.t('tasks.copy.archive.generate', scope: :dkdeploy)

      # generate an exclude.txt file with the patterns to be excluded
      exclude_content = copy_exclude.join("\n")
      File.write(copy_plugin.local_exclude_path, exclude_content)

      # build the tar archive excluding the patterns from exclude.txt
      within copy_source do
        execute :tar, '-X ' + copy_plugin.local_exclude_path, '-cpzf', copy_plugin.local_archive_path, '.'
      end
    end
  end

  # Copies the tar archive on the remote server
  # extracting it to the configured directory.
  #
  task :copy_archive_to_server do
    on release_roles :app do
      info I18n.t('file.upload', file: 'archive', target: copy_plugin.remote_tmp_dir, scope: :dkdeploy)
      execute :mkdir, '-p', copy_plugin.remote_tmp_dir

      upload! copy_plugin.local_archive_path, copy_plugin.remote_tmp_dir

      info I18n.t('directory.create', directory: release_path, scope: :dkdeploy)
      execute :mkdir, '-p', release_path

      within release_path do
        info I18n.t('tasks.copy.archive.extract', target: release_path, scope: :dkdeploy)
        execute :tar, '-xpzf', copy_plugin.remote_archive_path
      end
    end
  end

  # Cleans up the local and remote temporary directories
  #
  task :clean_up_temporary_sources do
    # remove the local temporary directory
    run_locally do
      info I18n.t('file.remove', path: copy_plugin.local_tmp_dir, scope: :dkdeploy)
      execute :rm, '-rf', copy_plugin.local_tmp_dir
    end

    # removes the remote temp path including the uploaded archive
    on release_roles :app do
      info I18n.t('file.remove', path: copy_plugin.remote_archive_path, scope: :dkdeploy)
      execute :rm, '-rf', copy_plugin.remote_tmp_dir
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    set :current_revision, I18n.t('log.revision_log_message', copy_source: fetch(:copy_source), time: Time.now, scope: :dkdeploy)
  end
end
