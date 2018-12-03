include Capistrano::DSL

module Dkdeploy
  module Helpers
    # Class for the capistrano copy
    #
    module FileSystem
      # Adds the absolute path prefix to the given relative path depending whether this needs to be in shared or release path.
      #
      # @param release_or_shared_path [Symbol] symbol of :shared_path or :release_path
      # @param path [String] the relative path
      # @return [String] absolute path
      def map_path_in_release_or_shared_path(release_or_shared_path, path)
        prefix_path = release_or_shared_path == :shared_path ? shared_path : release_path
        prefix_path.join(path)
      end

      # Resolves the symlink path to its target, otherwise returns the path without any changing
      # Note: the function can only be run within SSHKit context
      #
      # @param context [SSHKit::Backend::Netssh] SSHKit context
      # @param path [String] path to resolve
      # @return [String]
      def resolve_path_if_symlink(context, path)
        return context.capture :readlink, '-f', path if context.test " [ -L #{path} ] "

        path
      end

      # Iterates over the given paths' array, resolves symlinks and merges them together
      # Example merge_paths_with_resolved_symlinks [p_1, symlink_1, p_2], 'dkdeploy-core.dev' -> [p_1, symlink_1, p_2, resolved_symlink_1]
      # Note: the function can only be run within SSHKit context

      # @param context [SSHKit::Backend::Netssh] SSHKit context
      # @param paths [Array] array with paths to resolve
      # @return [Array] the merged array with paths
      def merge_paths_with_resolved_symlinks(context, *paths)
        paths.each do |path|
          resolved_path = resolve_path_if_symlink context, path
          paths.push resolved_path unless paths.include? resolved_path
        end
        paths
      end

      # Applies file owner/group/mode permissions to path on host via Capistrano - optionally recursively
      def apply_file_access_permissions(context, host, path, access_properties, force_recursive = false) # rubocop:disable Metrics/AbcSize
        unless context.test " [ -e #{path} ] "
          context.error I18n.t('resource.not_exists_on_host', resource: path, host: host.hostname, scope: :dkdeploy)
          return
        end

        # if the access properties should be applied recursively
        recursive = access_properties.fetch(:recursive, false) || force_recursive
        recursive = recursive ? '-R' : ''

        resolved_path = resolve_path_if_symlink(context, path)

        # change owner if set
        context.execute :chown, recursive, access_properties.fetch(:owner), resolved_path if access_properties.key?(:owner)

        # change group if set
        context.execute :chgrp, recursive, access_properties.fetch(:group), resolved_path if access_properties.key?(:group)

        # change mode if set
        context.execute :chmod, recursive, access_properties.fetch(:mode), resolved_path if access_properties.key?(:mode)
      end
    end
  end
end
