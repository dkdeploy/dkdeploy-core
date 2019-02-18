# frozen_string_literal: true

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
      File.write(local_exclude_path, exclude_content)

      # build the tar archive excluding the patterns from exclude.txt
      within copy_source do
        execute :tar, '-X ' + local_exclude_path, '-cpzf', local_archive_path, '.'
      end
    end
  end

  # Copies the tar archive on the remote server
  # extracting it to the configured directory.
  #
  task :copy_archive_to_server do
    on release_roles :all do
      info I18n.t('file.upload', file: 'archive', target: remote_tmp_dir, scope: :dkdeploy)
      execute :mkdir, '-p', remote_tmp_dir

      upload! local_archive_path, remote_tmp_dir

      info I18n.t('directory.create', directory: release_path, scope: :dkdeploy)
      execute :mkdir, '-p', release_path

      within release_path do
        info I18n.t('tasks.copy.archive.extract', target: release_path, scope: :dkdeploy)
        execute :tar, '-xpzf', remote_archive_path
      end
    end
  end

  # Cleans up the local and remote temporary directories
  #
  task :clean_up_temporary_sources do
    # remove the local temporary directory
    run_locally do
      info I18n.t('file.remove', path: fetch(:copy_local_tmp_dir), scope: :dkdeploy)
      execute :rm, '-rf', fetch(:copy_local_tmp_dir)
    end

    # removes the remote temp path including the uploaded archive
    on release_roles :all do
      info I18n.t('file.remove', path: remote_archive_path, scope: :dkdeploy)
      execute :rm, '-rf', remote_archive_path
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    set :current_revision, I18n.t('log.revision_log_message', copy_source: fetch(:copy_source), time: Time.now, scope: :dkdeploy)
  end

  # Archive path in a local temporary directory
  #
  # @return [String]
  def local_exclude_path
    File.join fetch(:copy_local_tmp_dir), 'exclude.txt'
  end

  # Archive path in a local temporary directory
  #
  # @return [String]
  def local_archive_path
    File.join fetch(:copy_local_tmp_dir), fetch(:copy_archive_filename)
  end

  # Remote temporary directory path
  #
  # @return [String]
  def remote_tmp_dir
    File.join fetch(:tmp_dir), application
  end

  # Archive path in a remote temporary directory
  #
  # @return [String]
  def remote_archive_path
    File.join remote_tmp_dir, fetch(:copy_archive_filename)
  end
end
