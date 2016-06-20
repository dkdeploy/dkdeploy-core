require 'erb'
require 'capistrano/i18n'
require 'dkdeploy/i18n'

include Capistrano::DSL
include SSHKit::DSL

namespace :apache do
  desc 'Render .htaccess to web root from erb template(s)'
  task :htaccess do |_, args|
    local_web_root_path = ask_array_variable(args, :local_web_root_path, 'questions.local_web_root_path')

    run_locally do
      apache_configuration_path = File.join 'config', 'etc', 'apache2', 'conf'
      htaccess_file_path = File.join apache_configuration_path, '.htaccess.erb'
      destination_htaccess_file_path = File.join local_web_root_path, '.htaccess'

      if File.exist? htaccess_file_path
        info I18n.t('tasks.apache.htaccess.render', scope: :dkdeploy)
        htaccess_template = ERB.new File.read(htaccess_file_path)

        # write the new htaccess file content to the target .htaccess file
        File.open(destination_htaccess_file_path, 'w') do |io|
          io.write htaccess_template.result(binding)
        end
      end
    end
  end
end
