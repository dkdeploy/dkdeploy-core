# frozen_string_literal: true

# custom file access properties
set :custom_file_access, {
  app: {
    release_path: {
      catalog: {
        owner: 'test-user',
        group: 'test-group',
        mode: 'u+rwx,g+rwx,o-wx',
        recursive: true
      }
    }
  }
}
