module Dkdeploy
  # Global static methods
  #
  module Constants
    #####################################################
    # General constants
    #####################################################

    # Copy source path
    #
    # @return [String]
    def copy_source
      fetch :copy_source, '.'
    end

    # Local Dump Path
    #
    # @return [String]
    def local_dump_path
      fetch :local_dump_path, 'temp'
    end

    # Copy exclude pattern
    #
    # @return [Array]
    def copy_exclude
      fetch :copy_exclude, []
    end

    # Application name
    #
    # @return [String]
    def application
      fetch(:application)
    end

    # Assets path
    #
    # @return [String]
    def assets_path
      File.join shared_path, 'assets'
    end

    # File path to remote database config file
    #
    # @return [String]
    def remote_database_config_path
      File.join shared_path, 'config', "db_settings.#{fetch(:stage)}.yaml"
    end

    # File path to local database config file
    #
    # @return [String]
    def local_database_config_path
      File.join 'temp', "db_settings.#{fetch(:stage)}.yaml"
    end

    # Default timestamp format for database dump files
    #
    # @return [String]
    def datetime_format
      '%Y-%m-%d_%H-%M'
    end

    # List of table names to be ignored by default when dumping from database
    #
    # @return [String]
    def default_ignore_tables
      %w[]
    end

    # List of table names to be ignored when dumping from database defined via Capistrano variable or environment variable
    #
    # @return [Array]
    def additional_ignore_tables
      env_array_list = ENV.fetch('ADDITIONAL_IGNORE_TABLES', '').split ' '
      cap_array_list = fetch(:additional_ignore_tables, [])
      env_array_list | cap_array_list
    end

    # List of table names to be ignored when dumping from database
    #
    # @return [String]
    def ignore_tables
      default_ignore_tables | additional_ignore_tables
    end
  end
end
