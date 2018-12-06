include Capistrano::DSL

require 'dkdeploy/i18n'

namespace :current_folder do
  desc "Delete current folder unless it's a symlink"
  task :remove_unlesss_symlinked do
    on release_roles :all do
      if test "[ -d #{current_path} && ! -L #{current_path} ]"
        execute :rm, '-rf', current_path
      else
        info I18n.t('info.ignoring_current_folder', scope: :dkdeploy)
      end
    end
  end
end
