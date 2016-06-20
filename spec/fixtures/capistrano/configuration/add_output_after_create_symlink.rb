
after 'deploy:symlink:release', '--dummy-task-name' do
  run_locally do
    # rubocop:disable UnneededPercentQ
    info %q(Task 'deploy:symlink:release' executed)
  end
end
