require 'tmpdir'
require 'capistrano/scm/plugin'
require 'capistrano/i18n'
require 'dkdeploy/i18n'

include Capistrano::DSL

module Dkdeploy
  module SCM
    # Class for the capistrano copy
    #
    class Copy < Capistrano::SCM::Plugin
      def set_defaults
        set_if_empty :copy_source, 'htdocs'
        set_if_empty :copy_exclude, Array[
          'vendor/bundle/**',
          'Gemfile*',
          '**/.git',
          '**/.svn',
          '**/.DS_Store',
          '.settings',
          '.project',
          '.buildpath',
          'Capfile',
          'Thumbs.db',
          'composer.lock'
        ]
      end

      def register_hooks
        after 'deploy:new_release_path', 'copy:create_release'
        before 'deploy:check', 'copy:check'
        before 'deploy:set_current_revision', 'copy:set_current_revision'
      end

      def define_tasks
        eval_rakefile File.expand_path('../copy.rake', __FILE__)
      end

      # Archive filename as singleton
      # Note: if the archive filename doesn't already exist it will be generated
      #
      # @return [String]
      def archive_filename
        @archive_filename ||= Dir::Tmpname.make_tmpname [application + '_', '.tar.gz'], nil
      end

      # Local temporary directory path as singleton
      # Note: if the directory doesn't already exist it will be created
      #
      # @return [String]
      def local_tmp_dir
        @local_tmp_dir ||= Dir.mktmpdir
      end

      # Archive path in a local temporary directory
      #
      # @return [String]
      def local_exclude_path
        File.join local_tmp_dir, 'exclude.txt'
      end

      # Archive path in a local temporary directory
      #
      # @return [String]
      def local_archive_path
        File.join local_tmp_dir, archive_filename
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
        File.join remote_tmp_dir, archive_filename
      end
    end
  end
end
