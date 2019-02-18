# frozen_string_literal: true

require 'yaml'

include Capistrano::DSL

module Dkdeploy
  module Helpers
    # DB related helpers
    module DB
      def db_dump_file(infix = '')
        date = Time.now.strftime(datetime_format)
        ['database', fetch(:stage), infix, date].join('-') << '.sql'
      end

      def db_dump_file_content(table_name = nil)
        db_dump_file ['content', table_name].compact.join('-')
      end

      def db_dump_file_structure(table_name = nil)
        db_dump_file ['structure', table_name].compact.join('-')
      end

      def db_settings_hash
        {
          'database' => {
            'host' => fetch(:db_host),
            'port' => fetch(:db_port),
            'name' => fetch(:db_name),
            'username' => fetch(:db_username),
            'password' => fetch(:db_password),
            'charset' => fetch(:db_charset)
          }
        }
      end

      # Read db settings for given context
      #
      # @param context [SSHKit::Backend::Netssh] SSHKit context
      # @return [Hash] Hash with database settings
      def read_db_settings_for_context(context)
        unless context.test("[ -f #{remote_database_config_path} ]")
          context.error I18n.t('errors.database_config_file_missing', scope: :dkdeploy)
          return
        end
        json_string = context.download! remote_database_config_path
        YAML.safe_load(json_string).fetch('database')
      end
    end
  end
end
