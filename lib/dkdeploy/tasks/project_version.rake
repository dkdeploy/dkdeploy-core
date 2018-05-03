require 'capistrano/i18n'
require 'dkdeploy/i18n'
require 'dkdeploy/constants'

include Capistrano::DSL

namespace :project_version do
  desc 'Update Version file on server'
  task :update, :version_file_path do |_, args|
    version_file_path = ask_variable(args, :version_file_path, 'questions.version_file_path')
    remote_version_file = File.join release_path, version_file_path, 'Version'
    local_version_file = 'Version'

    unless File.exist? local_version_file # check if the local version file exists
      run_locally do
        error I18n.t('file.not_exists', file: local_version_file, scope: :dkdeploy)
        exit 1
      end
    end

    on release_roles :app do
      info I18n.t('tasks.project_version.update.update', scope: :dkdeploy)
      # remove the to be replaced remote version file
      execute :rm, '-f', remote_version_file if test " [ -f #{remote_version_file} ] "
      # upload the current version file
      upload! local_version_file, remote_version_file
    end
  end
end
