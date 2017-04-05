require 'capistrano/i18n'
require 'dkdeploy/i18n'

include Capistrano::DSL

namespace :bower do
  desc 'Runs given Bower command in given path'
  task :run, :bower_command, :bower_path do |_, args|
    bower_command = ask_variable(args, :bower_command, 'questions.bower.command') { |question| question.default = 'help' }
    bower_path = ask_variable(args, :bower_path, 'questions.bower.path') { |question| question.default = 'htdocs' }

    run_locally do
      if test("[ -d #{bower_path} ]")
        bower_file_path = File.join(bower_path, 'bower.json')
        if test("[ -f #{bower_file_path} ]")
          within bower_path do
            execute :bower, bower_command
          end
        else
          warn I18n.t('tasks.bower.skipping_directory_with_missing_bower_file', bower_path: bower_path, scope: :dkdeploy)
          next
        end
      else
        warn I18n.t('tasks.bower.skipping_missing_directory', bower_path: bower_path, scope: :dkdeploy)
        next
      end
    end
  end

  task :run_all, :bower_command, :bower_paths do |_, args|
    bower_command = ask_variable(args, :bower_command, 'questions.bower.command') { |question| question.default = 'help' }
    bower_paths = ask_array_variable(args, :bower_paths, 'questions.bower.paths')

    run_locally do
      bower_paths.each do |bower_path|
        if test("[ -d #{bower_path} ]")
          current_bower_file_path = File.join(bower_path, 'bower.json')
          if test("[ -f #{current_bower_file_path} ]")
            within bower_path do
              execute :bower, bower_command
            end
          else
            warn I18n.t('tasks.bower.skipping_directory_with_missing_bower_file', bower_path: bower_path, scope: :dkdeploy)
            next
          end
        else
          warn I18n.t('tasks.bower.skipping_missing_directory', bower_path: bower_path, scope: :dkdeploy)
          next
        end
      end
    end
  end
end
