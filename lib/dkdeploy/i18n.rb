require 'i18n'

en = {
  file: {
    not_exists: 'File %{file} does not exist.',
    not_exists_or_not_accessible_on_host: 'File %{file} does not exist on host %{host} or is not accessible.',
    not_exists_on_host: 'File %{file} does not exit on host %{host}.',
    upload: 'Uploading %{file} to %{target}.',
    download: 'Downloading %{file} to %{target}.',
    download_from_host: 'Downloading %{file} to %{target} from %{host}.',
    copy: 'Copying %{file} to %{target}.',
    remove: 'Removing %{path}.'
  },
  directory: {
    create: 'Creating directory %{directory}.',
    not_exists: 'Directory %{directory} does not exist.',
    not_exists_on_host: 'Directory %{directory} does not exit on host %{host}.'
  },
  dsl: {
    invoke_for_server: {
      set_filter: "Invoking task '%{task}' for server '%{host}'"
    }
  },
  resource: {
    not_exists_on_host: 'The resource %{resource} does not exist on host %{host}.',
    empty_selected_custom_file_access: "The variable 'selected_custom_file_access' is empty. Aborting task...",
    skipping_selected_custom_file_access: "Skipped setting custom_file_access permissions for '%{path}' because it is not mentioned in selected_custom_file_access!"
  },
  configuration: {
    argument_missing: "The '%{name}' argument missing.",
    argument_or_configuration_missing: "The '%{name}' argument or '%{variable}' configuration variable missing."
  },
  questions: {
    database: {
      host: 'Please enter the hostname/IP of the database server',
      port: 'Please enter the port of the database server',
      name: 'Please enter the database name',
      username: 'Please enter the database username',
      password: 'Please enter the database password',
      table_name: 'Please enter the table name',
      table_names: 'Please enter a list of table names (entries separated by spaces)',
      charset: 'Please enter the database character set',
      zipped_db_file: 'Please enter the name of the zipped SQL script file'
    },
    selected_custom_file_access: {
      paths: 'Please enter a list of paths (entries separated by spaces)'
    },
    path: 'Please enter a local path',
    file_name: 'Please enter a file name',
    username: 'Please enter a username',
    password: 'Please enter a password',
    compass_sources: 'Please enter compass sources (entries separated by spaces)',
    compass_compile_arguments: 'Please enter compass compile arguments (entries separated by spaces)',
    asset_folders: 'Please enter asset folders (entries separated by spaces)',
    asset_default_content: 'Please enter asset default content (entries separated by spaces)',
    local_web_root_path: 'Please enter a local web root path',
    version_file_path: 'Please enter a version file path',
    dir_names: 'Please specify the direcotory names you wish to create'
  },
  success: {
    settings_uploaded: 'The given database settings have been uploaded'
  },
  errors: {
    file_not_found: 'File not found.',
    password_was_empty: 'Password was empty. Please enter a password.',
    connection_failed: 'Connection to database could not be established',
    database_config_file_missing: 'Unable to locate database config file on remote server.',
    variable_content_is_neither_string_nor_array: "Error setting value of variable '%{variable_name}'. This is neither a (by space splittable) string nor an array!"
  },
  info: {
    local_md5: 'Local MD5 hash: %{md5_hash}',
    remote_md5: 'Remote MD5 hash: %{md5_hash}',
    md5_match: 'Local MD5 hash matches remote MD5 hash. Nothing to do!',
    ignoring_current_folder: 'Ignoring current folder because either it does not exist or it is symlinked.'
  },
  tasks: {
    apache: {
      htaccess: {
        render: 'Rendering .htaccess file.'
      }
    },
    assets: {
      add_htpasswd: {
        successfully_created: 'htpasswd file successfully created.'
      },
      cleanup: 'Cleaning folder %{folder}.',
      download: 'Downloading %{folder}',
      upload: 'Uploading %{file}',
      upload_extract: 'Extracting %{file}',
      exclude_file_not_found: "No exclude file found. To use set variable 'assets_exclude_file'"
    },
    copy: {
      archive: {
        generate: 'Generating the tar archive.',
        extract: 'Extracting archive to %{target}.'
      }
    },
    maintenance: {
      enabled: 'The %{mode} maintenance mode has successfully been enabled.',
      disabled: 'The %{mode} maintenance mode has successfully been disabled.',
      can_not_disable_by_reason_of_permanent: "Maintenance permanent mode has been enabled. Please call the task 'maintenance:disable_permanent'."
    },
    mysql: {
      clear_slow_log: 'MySQL slow log file %{file} on host %{host} has been cleared',
      analyze_slow_log: 'Generating slow log analyze file for host %{host)'
    },
    project_version: {
      update: {
        update: 'Updating the Version file.'
      }
    },
    utils: {
      rsync: {
        no_host: 'No hosts for rsync found. Please check configuration "rsync_roles".',
        use_host: "Use host '%{host}' for rsync."
      }
    }
  },
  log: {
    revision_log_message: "Local deployment for directory '%{copy_source}' at '%{time}'"
  },
  error_during_deployment: 'Error occurred at deployment. Rollback to old release',
  rollback_tasks: "Calling tasks '%{tasks_for_rollback}' for rollback action",
  failing_on_purpose: 'Failing this deployment on purpose!',
  rollback_finished: 'Rollback finished',
  keep_rollback_archives: 'Keeping %{keep_rollback_archives} of %{rollback_archives} rolled back releases on %{host}',
  setting_verbosity: 'Setting verbosity level to: %{verbosity_level} (from: %{old_verbosity})',
  resetting_verbosity: 'Reset verbosity level to: %{old_verbosity} (from: %{verbosity_level})'
}

capistrano_i18n_overwritten = {
  revision_log_message: "%{sha} on release '%{release}' by '%{user}'"
}

I18n.backend.store_translations(:en, dkdeploy: en)
I18n.backend.store_translations(:en, capistrano: capistrano_i18n_overwritten)

I18n.enforce_available_locales = true if I18n.respond_to?(:enforce_available_locales=)
