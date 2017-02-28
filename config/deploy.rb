lock '3.5.0'

set :application, 'SlideHub'
set :rbenv_type, :user # :system or :user
set :rbenv_ruby, '2.2.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w(rake gem bundle ruby rails)
set :rbenv_roles, :web # default value

# For Container Default Value
set :image_version, ENV['VERSION'] || 'latest'

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

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
end

def template(from, to, data, as_root = false)
  template_path = File.dirname(__FILE__) + "/deploy/templates/#{from}"
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to

  execute :sudo, :chmod, "644 #{to}"
  execute :sudo, :chown, "root:root #{to}" if as_root == true
end
