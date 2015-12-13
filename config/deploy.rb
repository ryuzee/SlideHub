lock '3.2.1'

set :application, 'open-slideshare-v2'
set :repo_url, 'git@github.com:ryuzee/open-slideshare-v2.git'
set :deploy_to, '/opt/application'
set :keep_releases, 5

set :rbenv_type, :user # :system or :user
set :rbenv_ruby, '2.2.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w(rake gem bundle ruby rails)
set :rbenv_roles, :all # default value

set :linked_dirs, %w(log tmp/backup tmp/pids tmp/cache tmp/sockets vendor/bundle)
# set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_pid, '/tmp/unicorn.pid'
set :unicorn_config_path, "#{release_path}/config/unicorn.rb"

set :bundle_jobs, 4

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

before 'deploy:migrate', 'deploy:db_compatibility_check'
after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 20 do
      invoke 'unicorn:legacy_restart'
    end
  end

  desc 'DB Compatibility Check'
  task :db_compatibility_check do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'ossjob:db_compatibility_check'
        end
      end
    end
  end
end
