require 'i18n'
require 'dkdeploy/i18n'
require 'dkdeploy/helpers/common'
require 'dkdeploy/helpers/assets'
require 'dkdeploy/interaction_handler/password'
require 'dkdeploy/constants'

include Capistrano::DSL
include SSHKit::DSL
include Dkdeploy::Helpers::Common
include Dkdeploy::Helpers::Assets
include Dkdeploy::Constants

namespace :assets do
  desc 'Compiles sass files'
  task :compile_compass, :compass_sources, :compass_compile_arguments do |_, args|
    compass_sources = ask_array_variable(args, :compass_sources, 'questions.compass_sources')
    compass_compile_arguments = ask_array_variable(args, :compass_compile_arguments, 'questions.compass_compile_arguments')
    compass_sources.each do |path|
      config_path = File.join path, 'config.rb'
      run_locally do
        # noinspection RubyArgCount
        if test "[ -f #{config_path} ]"
          execute :compass, 'compile', path, '--config', config_path, *compass_compile_arguments
        else
          error I18n.t('file.not_exists', file: config_path, scope: :dkdeploy)
        end
      end
    end
  end

  desc 'Add .htpasswd file to assets folder'
  task :add_htpasswd, :username, :password do |_, args|
    username = ask_variable(args, :username, 'questions.username') { |question| question.default = 'dkdeploy' }
    password = ask_variable(args, :password, 'questions.password') { |question| question.echo = '*' }
    htpasswd_path = File.join(shared_path, '.htpasswd')

    if password.empty?
      run_locally do
        error I18n.t('errors.password_was_empty', scope: :dkdeploy)
        exit 1
      end
    end

    on release_roles :web do
      info I18n.t('directory.create', scope: :dkdeploy)
      execute :mkdir, '-p', shared_path
      execute :htpasswd, '-c', htpasswd_path, username, interaction_handler: Dkdeploy::InteractionHandler::Password.new(password)
      info I18n.t('tasks.assets.add_htpasswd.successfully_created', scope: :dkdeploy)
    end
  end

  desc 'remove contents of the shared assets folder on the server'
  task :cleanup, :asset_folders do |_, args|
    asset_folders = ask_array_variable(args, :asset_folders, 'questions.asset_folder')

    on release_roles :web do
      asset_folders.each do |asset_folder|
        info I18n.t('tasks.assets.cleanup', folder: asset_folder, scope: :dkdeploy)
        path = File.join assets_path, asset_folder
        execute :rm, '-rf', path
        execute :mkdir, '-p', path
      end
    end
  end

  desc 'Copy contents of the configured asset folders on the server to the local ./temp/assets directory'
  task :download, :asset_folders do |_, args|
    asset_folders = ask_array_variable(args, :asset_folders, 'questions.asset_folders')

    asset_folders.each do |folder|
      assets_download folder
    end
  end

  desc 'Copy asset contents from the local ./temp/assets directory to the server'
  task :update, :asset_folders do |_, args|
    asset_folders = ask_array_variable(args, :asset_folders, 'questions.asset_folders')

    asset_folders.each do |tar|
      assets_upload tar
    end
  end

  desc 'Add default content from ./config/preseed/'
  task :add_default_content, :asset_default_content do |_, args|
    asset_default_content = ask_array_variable(args, :asset_default_content, 'questions.asset_default_content')

    config_path = File.join 'config', 'preseed'
    on release_roles :web do
      asset_default_content.each do |asset|
        assets_upload asset, config_path
      end
    end
  end
end
