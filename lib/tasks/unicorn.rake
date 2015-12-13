namespace :unicorn do
  ##
  # Tasks
  ##
  desc 'Start unicorn for development env.'
  task :start_dev do
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c #{config} -E development -D -l 3000"
  end

  desc 'Start unicorn for production env.'
  task :start do
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c #{config} -E production -D -l 3000"
  end

  desc 'Stop unicorn'
  task :stop do
    unicorn_signal :QUIT
  end

  desc 'Restart unicorn with USR2'
  task :restart do
    unicorn_signal :USR2
  end

  desc 'Increment number of worker processes'
  task :increment do
    unicorn_signal :TTIN
  end

  desc 'Decrement number of worker processes'
  task :decrement do
    unicorn_signal :TTOU
  end

  desc 'Unicorn pstree (depends on pstree command)'
  task :pstree do
    sh "pstree '#{unicorn_pid}'"
  end

  def unicorn_signal(signal)
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    File.read('/tmp/unicorn.pid').to_i
  rescue Errno::ENOENT
    raise "Unicorn doesn't seem to be running"
  end
end
