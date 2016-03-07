lock '3.2.1'

set :application, 'SlideHub'
set :repo_url, 'git@github.com:ryuzee/SlideHub.git'
set :deploy_to, '/opt/application'
set :keep_releases, 5

set :rbenv_type, :user # :system or :user
set :rbenv_ruby, '2.2.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w(rake gem bundle ruby rails)
set :rbenv_roles, :web # default value

set :linked_dirs, %w(log tmp/backup tmp/pids tmp/cache tmp/sockets vendor/bundle)
# set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_pid, '/tmp/unicorn.pid'
set :unicorn_config_path, "#{release_path}/config/unicorn.rb"

set :bundle_jobs, 4

# For Container Default Value
set :image_version, ENV['VERSION'] || 'latest'

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

namespace :container do
  desc 'setup'
  task :setup do
    on roles(:container) do
      template 'docker_run.conf.erb', '/tmp/docker_run.conf', {}, true
      execute 'sudo mv /tmp/docker_run.conf /etc/init/docker_run.conf'
      template 'run_app.sh.erb', '/tmp/run_app.sh', {}, true
      execute 'sudo mv /tmp/run_app.sh /usr/local/bin/run_app.sh'
    end
  end

  desc 'deploy'
  task :deploy do
    on roles(:container) do
      execute "sudo bash /usr/local/bin/run_app.sh #{fetch(:image_version)}"
    end
  end

  desc 'deploy_from_local'
  task :deploy_from_local do
    on roles(:container) do
      execute 'sudo docker pull ryuzee/slidehub:latest'
      prefix = DateTime.now.strftime('%Y%m%d%H%M%s')
      cmd = <<"EOS"
        docker run -d \
        --env OSS_REGION=#{fetch(:oss_region)} \
        --env OSS_SQS_URL=#{fetch(:oss_sqs_url)} \
        --env OSS_BUCKET_NAME=#{fetch(:oss_bucket_name)} \
        --env OSS_IMAGE_BUCKET_NAME=#{fetch(:oss_image_bucket_name)} \
        --env OSS_USE_S3_STATIC_HOSTING=#{fetch(:oss_use_s3_static_hosting)} \
        --env OSS_AWS_SECRET_KEY=#{fetch(:oss_aws_secret_key)} \
        --env OSS_AWS_ACCESS_ID=#{fetch(:oss_aws_access_id)} \
        --env OSS_USE_AZURE=#{fetch(:oss_use_azure)} \
        --env OSS_AZURE_CONTAINER_NAME=#{fetch(:oss_azure_container_name)} \
        --env OSS_AZURE_IMAGE_CONTAINER_NAME=#{fetch(:oss_azure_image_container_name)} \
        --env OSS_AZURE_CDN_BASE_URL=#{fetch(:oss_azure_cdn_base_url)} \
        --env OSS_AZURE_QUEUE_NAME=#{fetch(:oss_azure_queue_name)} \
        --env OSS_AZURE_STORAGE_ACCESS_KEY=#{fetch(:oss_azure_storage_access_key)} \
        --env OSS_AZURE_STORAGE_ACCOUNT_NAME=#{fetch(:oss_azure_storage_account_name)} \
        --env OSS_SECRET_KEY_BASE=#{fetch(:oss_secret_key_base)} \
        --env OSS_DB_NAME=#{fetch(:oss_db_name)} \
        --env OSS_DB_USERNAME=#{fetch(:oss_db_username)} \
        --env OSS_DB_PASSWORD=#{fetch(:oss_db_password)} \
        --env OSS_DB_URL=#{fetch(:oss_db_url)} \
        --env OSS_SMTP_SERVER=#{fetch(:oss_smtp_server)} \
        --env OSS_SMTP_PORT=#{fetch(:oss_smtp_port)} \
        --env OSS_SMTP_USERNAME=#{fetch(:oss_smtp_username)} \
        --env OSS_SMTP_PASSWORD=#{fetch(:oss_smtp_password)} \
        --env OSS_SMTP_AUTH_METHOD=#{fetch(:oss_smtp_auth_method)} \
        --env OSS_PRODUCTION_HOST=#{fetch(:oss_production_host)} \
        --env OSS_ROOT_URL=#{fetch(:oss_root_url)} \
        -P --name slidehub#{prefix} ryuzee/slidehub
EOS
      run_app(cmd)
      clean_container
    end
  end
end

def run_app(docker_cmd)
  execute 'sudo docker pull ryuzee/slidehub:latest'
  container_id = capture("sudo #{docker_cmd}")
  port = capture("sudo docker port #{container_id} 3000").to_s.split(':')[1]
  puts port
  # confirm running
  cmd = "curl -LI http://127.0.0.1:#{port} -o /dev/null -w '%{http_code}\\n' -s"
  cnt = 0
  loop do
    execute "echo 'sleep 20 sec...'"
    sleep 20
    cnt += 1
    if cnt == 10
      error = Exception.new('An error that should abort and rollback deployment')
      raise error
    end
    begin
      container_status = capture(cmd).to_i
      if container_status == 200
        break
      end
    rescue Exception => e
      puts e.inspect
    end
  end
  data = { port: port }
  template 'nginx_default.erb', '/tmp/default', data, true
  execute 'sudo mv /tmp/default /etc/nginx/sites-available/default && sudo service nginx reload'
end

def clean_container
  containers = capture('sudo docker ps -q').to_s.split("\n")
  containers.shift
  containers.shift
  puts containers.inspect
  containers.each do |c|
    execute "sudo docker rm -f #{c}"
  end
end

def template(from, to, data, as_root = false)
  template_path = File.dirname(__FILE__) + "/deploy/templates/#{from}"
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to

  execute :sudo, :chmod, "644 #{to}"
  execute :sudo, :chown, "root:root #{to}" if as_root == true
end
