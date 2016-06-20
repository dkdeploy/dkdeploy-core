require 'capistrano/i18n'
require 'dkdeploy/i18n'
require 'dkdeploy/helpers/file_system'

include Capistrano::DSL
include SSHKit::DSL
include Dkdeploy::Helpers::FileSystem

namespace :file_access do
  desc 'Set standard defined owner and group on the shared and release path'
  task set_owner_group: [:set_owner_group_of_shared_path, :set_owner_group_of_release_path]

  desc 'Set standard defined owner and group on the shared path'
  task :set_owner_group_of_shared_path do
    on release_roles :app do
      paths = merge_paths_with_resolved_symlinks self, shared_path
      execute :chown, "#{fetch(:default_file_access_owner_of_shared_path)}:#{fetch(:default_file_access_group_of_shared_path)}", paths
    end
  end

  desc 'Set recursively standard defined owner and group on the release path'
  task :set_owner_group_of_release_path do
    on release_roles :app do
      paths = merge_paths_with_resolved_symlinks self, release_path
      execute :chown, '-R', "#{fetch(:default_file_access_owner_of_release_path)}:#{fetch(:default_file_access_group_of_release_path)}", paths
    end
  end

  desc 'Set standard defined file permissions on the shared and release path'
  task set_permissions: [:set_permissions_of_shared_path, :set_permissions_of_release_path]

  desc 'Set standard defined file permissions on the shared path'
  task :set_permissions_of_shared_path do
    on release_roles :app do
      paths = merge_paths_with_resolved_symlinks self, shared_path
      execute :chmod, fetch(:default_file_access_mode_of_shared_path), paths
    end
  end

  desc 'Set recursively standard defined file permissions on the release path'
  task :set_permissions_of_release_path do
    on release_roles :app do
      paths = merge_paths_with_resolved_symlinks self, release_path
      execute :chmod, '-R', fetch(:default_file_access_mode_of_release_path), paths
    end
  end

  desc 'Set custom defined owner, group and mode on paths'
  task :set_custom_access do
    fetch(:custom_file_access, {}).each do |role, paths_hash|
      on release_roles role do |host|
        release_or_shared_paths = paths_hash.select { |k, _| [:release_path, :shared_path].include? k } # allow only :release_path and :shared_path entries
        release_or_shared_paths.each do |release_or_shared_path, paths|
          paths.each do |path, access_properties|
            path = map_path_in_release_or_shared_path(release_or_shared_path, path.to_s) # build absolute path
            apply_file_access_permissions(self, host, path, access_properties)
          end
        end
      end
    end
  end

  desc 'Set custom defined owner, group and mode on paths positively selected by a list of paths'
  task :set_selected_custom_access, :selected_custom_file_access do |_, args|
    list_of_selected_paths = ask_array_variable(args, :selected_custom_file_access, 'questions.selected_custom_file_access.paths')
    if list_of_selected_paths.empty?
      run_locally do
        error I18n.t('resource.empty_selected_custom_file_access', scope: :dkdeploy)
        exit 1
      end
    end

    fetch(:custom_file_access, {}).each do |role, paths_hash|
      on release_roles role do |host|
        release_or_shared_paths = paths_hash.select { |k, _| [:release_path, :shared_path].include? k } # allow only :release_path and :shared_path entries
        release_or_shared_paths.each do |release_or_shared_path, paths|
          paths.each do |path, access_properties|
            unless list_of_selected_paths.include?(path)
              info I18n.t('resource.skipping_selected_custom_file_access', path: path, scope: :dkdeploy)
              next
            end
            path = map_path_in_release_or_shared_path(release_or_shared_path, path.to_s) # build absolute path
            apply_file_access_permissions(self, host, path, access_properties, true)
          end
        end
      end
    end
  end
end
