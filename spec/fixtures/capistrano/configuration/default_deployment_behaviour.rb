# frozen_string_literal: true

# Deploy workflow. See http://capistranorb.com/documentation/getting-started/flow/
after 'deploy:started', 'apache:htaccess'
after 'deploy:started', 'assets:compile_compass'
after 'deploy:updated', 'project_version:update'
after 'deploy:updated', 'file_access:set_owner_group'
after 'deploy:updated', 'file_access:set_permissions'
after 'deploy:updated', 'file_access:set_custom_access'
after 'deploy:updated', 'maintenance:enable'
after 'deploy:finished', 'maintenance:disable'
