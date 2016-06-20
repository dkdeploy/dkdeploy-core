module Dkdeploy
  # The RollbackManager module is a mixin for managing rollback tasks.
  module RollbackManager
    # Getter for rollback_tasks
    #
    # @return [Array]
    def rollback_tasks
      @rollback_tasks ||= []
    end

    # Add new rollback task
    #
    # @param [String]
    def add_rollback_task(task_name)
      rollback_tasks << task_name if Rake::Task.task_defined? task_name
    end
  end
end
