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
        set_if_empty :copy_archive_filename, -> { [fetch(:application), rand(0x100000000).to_s(36)].join('_') + '.tar.gz' }
        set_if_empty :copy_local_tmp_dir, Dir.mktmpdir
      end

      def register_hooks
        after 'deploy:new_release_path', 'copy:create_release'
        before 'deploy:check', 'copy:check'
        before 'deploy:set_current_revision', 'copy:set_current_revision'
      end

      def define_tasks
        # Don not use method "eval_rakefile" to load rake tasks.
        # "eval_rakefile" defined wrong context and use sskit dsl api instead of capistrano dsl.
        load File.expand_path('copy.rake', __dir__)
      end
    end
  end
end
