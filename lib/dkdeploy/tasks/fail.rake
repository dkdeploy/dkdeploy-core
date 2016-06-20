include Capistrano::DSL

namespace :deploy do
  desc 'Deployment task which fails every time'
  task :fail do
    raise I18n.t('failing_on_purpose', scope: :dkdeploy)
  end
end
