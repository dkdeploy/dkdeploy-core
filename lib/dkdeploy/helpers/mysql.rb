include Capistrano::DSL

module Dkdeploy
  module Helpers
    # Helpers for MySQL slow_log tasks
    module MySQL
      # checks for existence of mysql_sloq_log on server and prints error message if not present
      # @param file_path [String]
      # @return [Boolean]
      def slow_log_exists?(file_path)
        return true if !file_path.empty? && test("[ -f #{file_path} ]")
        error I18n.t('file.not_exists_or_not_accessible_on_host', file: file_path, host: server, scope: :dkdeploy)
        false
      end
    end
  end
end
