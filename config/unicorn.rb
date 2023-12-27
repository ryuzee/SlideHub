# From http://qiita.com/Salinger/items/5350b23f8b4e0dcdbe23
worker_processes Integer(ENV.fetch('WEB_CONCURRENCY', nil) || 3)
timeout Integer(ENV.fetch('WEB_TIMEOUT', nil) || 15)
preload_app true

listen '/tmp/unicorn.sock'
pid '/tmp/unicorn.pid'

before_fork do |_server, _worker|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile', ENV.fetch('RAILS_ROOT', nil))

  Signal.trap 'TERM' do
    logger.info('Unicorn master intercepting TERM and sending myself QUIT instead')
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    logger.info('Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT')
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

unless ENV.key?('RAILS_LOG_TO_STDOUT')
  stderr_path File.expand_path('log/unicorn.log', ENV.fetch('RAILS_ROOT', nil))
  stdout_path File.expand_path('log/unicorn.log', ENV.fetch('RAILS_ROOT', nil))
end
