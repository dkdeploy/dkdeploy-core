require 'tmpdir'
require 'capistrano/scm'
require 'capistrano/i18n'
require 'dkdeploy/i18n'
require 'dkdeploy/constants'

include Capistrano::DSL

module Dkdeploy
  # Class for the capistrano copy
  #
  class Copy
    include Dkdeploy::Constants

    # Provide a wrapper for the SCM that loads a strategy for the user.
    #
    # @param [Rake] context     The context in which the strategy should run
    # @param [Module] strategy  A module to include into the SCM instance. The
    #    module should provide the abstract methods of Capistrano::SCM
    #
    def initialize(context, strategy)
      @context = context
      singleton = class << self; self; end
      singleton.send(:include, strategy)
    end

    # Default copy strategy
    #
    module DefaultStrategy
      # Checks if the local source directory exists.
      #
      def check
        # scope object for the processing in the block
        me = self
        run_locally do
          unless Dir.exist? me.copy_source
            fatal I18n.t('directory.not_exists', name: me.copy_source, scope: :dkdeploy)
            exit 1
          end
        end
      end

      # Copies the source file structure to the server excluding the not wanted elements.
      #
      def release
        build_source_archive
        copy_archive_to_server
        clean_up_temporary_sources
      end

      # Builds a tar archive in a temporary directory
      # excluding files and folders matching the configured pattern.
      #
      def build_source_archive
        # scope object for the processing in the block
        me = self
        run_locally do
          info I18n.t('tasks.copy.archive.generate', scope: :dkdeploy)

          # generate an exclude.txt file with the patterns to be excluded
          File.open(me.local_exclude_path, 'w+') do |file|
            me.copy_exclude.each do |pattern|
              file.puts pattern
            end
          end

          # build the tar archive excluding the patterns from exclude.txt
          within me.copy_source do
            execute :tar, '-X ' + me.local_exclude_path, '-cpzf', me.local_archive_path, '.'
          end
        end
      end

      # Copies the tar archive on the remote server
      # extracting it to the configured directory.
      #
      def copy_archive_to_server # rubocop:disable Metrics/AbcSize
        # scope object for the processing in the block
        me = self
        on release_roles :app do
          info I18n.t('file.upload', file: 'archive', target: me.remote_tmp_dir, scope: :dkdeploy)
          execute :mkdir, '-p', me.remote_tmp_dir

          upload! me.local_archive_path, me.remote_tmp_dir

          info I18n.t('directory.create', directory: release_path, scope: :dkdeploy)
          execute :mkdir, '-p', release_path

          within release_path do
            info I18n.t('tasks.copy.archive.extract', target: release_path, scope: :dkdeploy)
            execute :tar, '-xpzf', me.remote_archive_path
          end
        end
      end

      # Cleans up the local and remote temporary directories
      #
      def clean_up_temporary_sources
        # scope object for the processing in the block
        me = self

        # remove the local temporary directory
        run_locally do
          info I18n.t('file.remove', path: me.local_tmp_dir, scope: :dkdeploy)
          execute :rm, '-rf', me.local_tmp_dir
        end

        # removes the remote archive
        on release_roles :app do
          info I18n.t('file.remove', path: me.remote_archive_path, scope: :dkdeploy)
          execute :rm, '-f', me.remote_archive_path
        end
      end

      # Fetches the current revision message
      def fetch_revision
        I18n.t('log.revision_log_message', copy_source: fetch(:copy_source), time: Time.now, scope: :dkdeploy)
      end
    end
  end
end
