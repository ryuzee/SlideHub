# -*- coding: utf-8 -*-
# From http://qiita.com/Salinger/items/5350b23f8b4e0dcdbe23
worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 15
preload_app true # 更新時ダウンタイム無し

listen '/tmp/unicorn.sock'
# listen "#{rails_root}/tmp/unicorn.sock"
pid '/tmp/unicorn.pid'
# pid "#{rails_root}/tmp/unicorn.pid"

before_fork do |_server, _worker|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile', ENV['RAILS_ROOT'])

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

# ログの出力
unless ENV.has_key?('RAILS_LOG_TO_STDOUT')
  stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
  stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
end
