include Capistrano::DSL

namespace :deploy do
  namespace :enhanced_symlinks do
    namespace :check do
      desc "Check directories to be linked exist in shared using the given hash 'enhanced_linked_dirs'"
      task :linked_dirs do
        next unless any? :enhanced_linked_dirs
        fetch(:enhanced_linked_dirs).each_key do |source|
          on release_roles :all do
            execute :mkdir, '-pv', shared_path.join(source)
          end
        end
      end

      desc "Check directories of files to be linked exist in shared using the given hash 'enhanced_linked_files'"
      task :make_linked_dirs do
        next unless any? :enhanced_linked_files
        fetch(:enhanced_linked_files).each_value do |target|
          on release_roles :all do
            execute :mkdir, '-pv', shared_path.join(target).dirname
          end
        end
      end

      desc "Check files to be linked exist in shared using the given hash 'enhanced_linked_files'"
      task :linked_files do
        next unless any? :enhanced_linked_files
        fetch(:enhanced_linked_files).each_key do |source|
          on release_roles :all do |host|
            unless test "[ -f #{shared_path.join source} ]"
              error t(:linked_file_does_not_exist, file: source, host: host)
              exit 1
            end
          end
        end
      end
    end

    namespace :symlink do
      desc "Symlink linked directories using the given hash 'enhanced_linked_dirs'"
      task :linked_dirs do
        next unless any? :enhanced_linked_dirs
        fetch(:enhanced_linked_dirs).each do |source, target|
          target = release_path.join(target)
          source = shared_path.join(source)
          on release_roles :all do
            execute :mkdir, '-pv', target.dirname
            unless test "[ -L #{target} ]"
              execute :rm, '-rf', target if test "[ -d #{target} ]"
              execute :ln, '-s', source, target
            end
          end
        end
      end

      desc "Symlink linked files using the given hash 'enhanced_linked_files'"
      task :linked_files do
        next unless any? :enhanced_linked_files
        fetch(:enhanced_linked_files).each do |source, target|
          target = release_path.join(target)
          source = shared_path.join(source)
          on release_roles :all do
            execute :mkdir, '-pv', target.dirname
            unless test "[ -L #{target} ]"
              execute :rm, target if test "[ -f #{target} ]"
              execute :ln, '-s', source, target
            end
          end
        end
      end
    end
  end
end
