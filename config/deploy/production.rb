set :branch, 'master'

# role :app, %w{vagrant@192.168.1.222}
# role :web, %w{vagrant@192.168.1.222}
# role :db,  %w{vagrant@192.168.1.222}

server '192.168.1.222', user: 'vagrant', roles: %w{web app db}, password: 'vagrant'

# set :ssh_options, {
#    keys: [File.expand_path(ENV['OSS_DEPLOY_KEY_PATH'])],
#    forward_agent: true,
#    auth_methods: %w(publickey)
#}

set :ssh_options, {
   config: false
}
