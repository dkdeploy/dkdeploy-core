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
      %w(
        cache_extensions cache_hash cache_imagesizes cache_md5params
        cache_pages cache_pagesection cache_sys_dmail_stat cache_treelist cache_typo3temp_log
        cachingframework_cache_hash cachingframework_cache_hash_tags cachingframework_cache_pages
        cachingframework_cache_pages_tags cachingframework_cache_pagesection
        cachingframework_cache_pagesection_tags sys_workspace_cache sys_workspace_cache_tags
        tt_news_cache tt_news_cache_tags tx_extbase_cache_object tx_extbase_cache_object_tags
        tx_extbase_cache_reflection tx_extbase_cache_reflection_tags tx_realurl_chashcache
        tx_realurl_pathcache tx_realurl_urldecodecache tx_realurl_urlencodecache be_users be_sessions
        sys_domain fe_users fe_sessions fe_session_data
        cf_cache_hash cf_cache_hash_tags cf_cache_pages cf_cache_pages_tags cf_cache_pagesection
        cf_cache_pagesection_tags cf_cache_rootline cf_cache_rootline_tags cf_extbase_datamapfactory_datamap
        cf_extbase_datamapfactory_datamap_tags cf_extbase_object cf_extbase_object_tags
        cf_extbase_reflection cf_extbase_reflection_tags cf_extbase_typo3dbbackend_queries
        cf_extbase_typo3dbbackend_queries_tags cf_extbase_typo3dbbackend_tablecolumns
        cf_extbase_typo3dbbackend_tablecolumns_tags
      )
    end

    # List of table names to be ignored when dumping from database defined via Capistrano variable or environment variable
    #
    # @return [String]
    def additional_ignore_tables
      env_string_list = ENV.fetch('ADDITIONAL_IGNORE_TABLES', '').split ' '
      cap_string_list = fetch(:additional_ignore_tables, '').split ' '
      env_string_list | cap_string_list
    end

    # List of table names to be ignored when dumping from database
    #
    # @return [String]
    def ignore_tables
      default_ignore_tables | additional_ignore_tables
    end

    #####################################################
    # Local temporary directory constants
    #####################################################

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

    #####################################################
    # remote paths constants
    #####################################################

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
