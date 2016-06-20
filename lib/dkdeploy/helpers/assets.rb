include Capistrano::DSL
include SSHKit::DSL

module Dkdeploy
  module Helpers
    # Helpers for Assets Tasks
    module Assets
      def assets_upload(name, folder = File.join('temp', 'assets')) # rubocop:disable Metrics/AbcSize
        FileUtils.mkdir_p folder
        on release_roles :web do
          targz = name + '.tar.gz'
          info I18n.t('tasks.assets.upload', file: targz, scope: :dkdeploy)
          execute :mkdir, '-p', assets_path
          upload! File.join(folder, targz), assets_path
          within assets_path do
            info I18n.t('tasks.assets.upload_extract', file: targz, scope: :dkdeploy)
            execute :tar, 'xzfp', targz
            execute :rm, '-f', targz
          end
          invoke 'file_access:set_custom_access'
        end
      end

      def assets_download(folder) # rubocop:disable Metrics/AbcSize
        FileUtils.mkdir_p File.join('temp', 'assets')
        assets_exclude_file = fetch(:asset_exclude_file) || ''
        on release_roles :web do
          if File.exist?(assets_exclude_file)
            exclude_filename = File.basename(assets_exclude_file)
            execute :rm, '-f', File.join(assets_path, exclude_filename)
            upload! assets_exclude_file, assets_path
            exclude_option = "-X #{File.join(assets_path, exclude_filename)}"
          else
            info I18n.t('tasks.assets.exclude_file_not_found', scope: :dkdeploy)
          end
          within assets_path do
            if test "[ -d #{assets_path}/#{folder} ]"
              info I18n.t('tasks.assets.download', folder: folder, scope: :dkdeploy)
              execute :tar, 'czfp', "#{folder}.tar.gz", exclude_option || '', folder
              download! File.join(assets_path, "#{folder}.tar.gz"), File.join('temp', 'assets')
              execute :rm, '-f', "#{folder}.tar.gz"
            else
              info I18n.t('tasks.assets.folder_not_found', folder: folder, scope: :dkdeploy)
            end
          end
        end
      end
    end
  end
end
