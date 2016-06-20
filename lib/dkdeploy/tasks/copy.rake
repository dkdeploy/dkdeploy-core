require_relative '../copy'

include Capistrano::DSL

namespace :copy do
  # Getter for copy strategy
  #
  def strategy
    @strategy ||= Dkdeploy::Copy.new(self, fetch(:copy_strategy, Dkdeploy::Copy::DefaultStrategy))
  end

  desc 'Check if all configuration variables and copy sources exist'
  task :check do
    strategy.check
  end

  desc 'Upload the source repository to releases'
  task :create_release do
    strategy.release
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    set :current_revision, strategy.fetch_revision
  end
end
