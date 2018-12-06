include Capistrano::DSL

require 'dkdeploy/rollback_manager'

# Install copy plugin
require 'dkdeploy/scm/copy'
install_plugin Dkdeploy::SCM::Copy

# Load dkdeploy tasks
load File.expand_path('../../dkdeploy/tasks/deploy.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/fail.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/maintenance.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/utils.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/file_access.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/assets.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/apache.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/project_version.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/db.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/enhanced_symlinks.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/current_folder.rake', __dir__)
load File.expand_path('../../dkdeploy/tasks/mysql.rake', __dir__)

# Hook into symlink related tasks
after 'deploy:check:linked_dirs', 'deploy:enhanced_symlinks:check:linked_dirs'
after 'deploy:check:linked_files', 'deploy:enhanced_symlinks:check:linked_files'
after 'deploy:check:make_linked_dirs', 'deploy:enhanced_symlinks:check:make_linked_dirs'
after 'deploy:symlink:linked_dirs', 'deploy:enhanced_symlinks:symlink:linked_dirs'
after 'deploy:symlink:linked_files', 'deploy:enhanced_symlinks:symlink:linked_files'

namespace :load do
  task :defaults do
    # Set default web root paths
    set(:local_web_root_path, -> { fetch(:copy_source) })
    set :remote_web_root_path, '.'

    # Set default version file path
    set :version_file_path, ''

    # default file owner
    set :default_file_access_owner_of_shared_path, 'www-data'
    set :default_file_access_owner_of_release_path, 'www-data'
    # default file group
    set :default_file_access_group_of_shared_path, 'www-data'
    set :default_file_access_group_of_release_path, 'www-data'
    # default file access mode
    set :default_file_access_mode_of_shared_path, 'u+rwX,g+rX,g-w,o-rwx'
    set :default_file_access_mode_of_release_path, 'u+rwX,g+rX,g-w,o-rwx'
    # custom file access properties
    set :custom_file_access, {}

    # Set default compass sources
    set :compass_sources, []
    set :compass_compile_arguments, []

    # Number of archives to keep around
    set :keep_rollback_archives, 5

    # List of filters for file_access:set_selected_custom_access
    set :selected_custom_file_access, []

    # Set assets configuration
    set :asset_default_content, []
    set :asset_exclude_file, ''
    set :asset_folders, []

    # Airbrush configuration
    set :format_options, command_output: true, log_file: nil, truncate: false

    # MySQL slow_log
    set :mysql_slow_log, ''
  end
end
