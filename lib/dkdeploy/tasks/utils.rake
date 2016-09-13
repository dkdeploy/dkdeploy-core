require 'capistrano/i18n'
require 'dkdeploy/i18n'

include Capistrano::DSL
include SSHKit::DSL

namespace :utils do
  desc 'Get current webroot path in releases'
  task :get_current_path do
    on primary :app do
      info capture :readlink, '-f', current_path
    end
  end

  desc 'Upload a file to current stage.'
  task :upload_file, :file_name do |_, args|
    file_name = ask_variable(args, :file_name, 'questions.file_name')
    run_locally do
      if file_name.empty?
        error I18n.t('configuration.argument_missing', name: 'file_name', scope: :dkdeploy)
        exit 1
      end
      # noinspection RubyArgCount
      unless test "[ -f #{file_name} ]"
        error I18n.t('file.not_exists', file: file_name, scope: :dkdeploy)
        exit 1
      end
    end
    regular_expression = "^#{fetch(:copy_source)}"
    server_filename = File.join current_path, file_name.sub(Regexp.new(regular_expression), '')
    on roles :app, :web do
      directory_name = File.dirname server_filename
      # noinspection RubyArgCount
      unless test "[ -d #{directory_name} ]"
        info I18n.t('directory.create', directory: directory_name, scope: :dkdeploy)
        execute :mkdir, '-p', directory_name
      end
      info I18n.t('file.upload', file: file_name, target: server_filename, scope: :dkdeploy)
      upload! file_name, server_filename
    end
  end

  desc 'Download a file to current stage.'
  task :download_file, :download_filename do |_, args|
    filename = ask_variable(args, :download_filename, 'questions.file_name')
    if filename.empty?
      run_locally do
        error I18n.t('configuration.argument_missing', name: 'download_filename', scope: :dkdeploy)
        exit 1
      end
    end
    remote_filename = File.join current_path, filename
    on roles :app, :web do |server|
      # noinspection RubyArgCount
      unless test "[ -f #{remote_filename} ]"
        error I18n.t('file.not_exists', file: remote_filename, scope: :dkdeploy)
        next
      end
      local_filename = File.join local_dump_path, "#{File.basename(filename, '.*')}.#{server.hostname}#{File.extname(filename)}"
      info I18n.t('file.download', file: remote_filename, target: local_filename, scope: :dkdeploy)
      download! remote_filename, local_filename
    end
  end

  desc 'Watch file on server'
  task :watch_file, :file_name do |_, args|
    file_name = args[:file_name] || fetch(:watch_file_name)
    on roles :all do |host|
      unless file_name
        error I18n.t('configuration.argument_or_configuration_missing', name: 'file_name', variable: 'watch_file_name', scope: :dkdeploy)
        exit 1
      end
      # noinspection RubyArgCount
      if test " [ -f #{file_name} ] "
        execute :tail, '-f', file_name
      else
        warn I18n.t('file.not_exists_on_host', file: file_name, host: host.hostname, scope: :dkdeploy)
      end
    end
  end

  desc 'Copy data to server with rsync'
  task :rsync do
    # Define local variables
    rsync_roles = fetch :rsync_roles, :app
    rsync_exclude = fetch :rsync_exclude, []
    rsync_path = fetch :rsync_path, fetch(:copy_source)
    # Append '/' to source directory
    rsync_path = File.join(rsync_path, '')

    rsync_command = %w(--verbose --recursive --perms --times --perms --perms --compress --force --cvs-exclude)

    # Build exclude parameter
    rsync_exclude.each do |exclude|
      rsync_command << '--exclude "' + exclude + '"'
    end
    # Add local source directory
    rsync_command << rsync_path

    capistrano_ssh_option = fetch(:ssh_options, {})

    run_locally do
      # Fetch hosts for rsync command
      hosts = roles rsync_roles
      if hosts.empty?
        error I18n.t('tasks.utils.rsync.no_host', scope: :dkdeploy)
        exit 1
      end

      hosts.each do |host|
        info I18n.t('tasks.utils.rsync.use_host', host: host.hostname, scope: :dkdeploy)
        ssh_option = 'ssh'
        ssh_option += ' -p ' + host.port.to_s unless host.port.nil?
        if capistrano_ssh_option.key? :keys
          capistrano_ssh_option[:keys].each do |file|
            ssh_option += " -i '#{file}'"
          end
        end

        user = host.user || capistrano_ssh_option[:user]

        ssh_host = ''
        ssh_host += user + '@' unless user.empty?
        ssh_host += host.hostname

        execute :rsync, rsync_command + ['--rsh="' + ssh_option + '"', ssh_host + ':' + release_path.to_s]
      end
    end
  end

  desc 'Create custom directories in shared path'
  task :create_custom_directories, :directories do |_, args|
    directories = ask_array_variable(args, :directories, 'questions.dir_names')

    on release_roles :app do
      directories.each do |directory|
        execute :mkdir, '-p', File.join(shared_path, directory)
      end
    end
  end

  desc 'Create local temporary directory'
  task :create_local_temp_directory do
    run_locally { execute :mkdir, '-p', local_dump_path }
  end
end
