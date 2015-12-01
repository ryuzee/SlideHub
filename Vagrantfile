# -*- mode: ruby -*-
# vi: set ft=ruby :
# =================================================#
# Ruby on Rails Development Environment            #
# U |  _"\ u U  /"\  u     ___     |"|    / __"| u #
#  \| |_) |/  \/ _ \/     |_"_|  U | | u <\___ \/  #
#   |  _ <    / ___ \      | |    \| |/__ u___) |  #
#   |_| \_\  /_/   \_\   U/| |\u   |_____||____/>> #
#   //   \\_  \\    >>.-,_|___|_,-.//  \\  )(  (__)#
#  (__)  (__)(__)  (__)\_)-' '-(_/(_")("_)(__)     #
# =================================================#
# you need to enable nfs on your local computer
# Ubuntu: sudo apt-get install nfs-kernel-server
# Mac   : sudo nfsd enable
Vagrant.configure(2) do |config|

  if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    puts '--- ERROR ---'
    puts 'This Vagrantfile is not compatible with Windows environment'
    puts 'exit program...'
    exit
  end

  unless Vagrant.has_plugin?('Bindfs')
    puts '--- WARNING ---'
    puts 'You need to install vagrant-bindfs plugin by the command as follow'
    puts 'exec vagrant plugin install vagrant-bindfs'
    puts 'exit program...'
    exit
  end

  config.vm.box = 'opscode-ubuntu-14.04'
  # config.vm.box_check_update = false
  config.vm.network 'forwarded_port', guest: 3000, host: 3001
  config.vm.network 'private_network', ip: '192.168.200.10'
  ### It's better to use NFS for performance
  config.vm.synced_folder File.dirname(__FILE__), '/vagrant-nfs', :nfs => { mount_options: ['dmode=777', 'fmode=777'] }
  config.bindfs.bind_folder '/vagrant-nfs', '/home/vagrant/myapp', :owner => 'vagrant', :group => 'vagrant', :'create-as-user' => true, :perms => 'u=rwx:g=rx:o=rx', :'create-with-perms' => 'u=wrx:g=rwx:o=rwx', :'chown-ignore' => true, :'chgrp-ignore' => true, :'chmod-ignore' => true

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = false
    vb.memory = '1024'
  end

  config.vm.provision 'shell', :privileged => false, inline: <<-SHELL
    echo "====== Installing packages via apt ======"
    sudo apt-get update
    sudo apt-get -y install language-pack-ja wget curl zip unzip git sqlite3 libsqlite3-dev
    sudo apt-get -y install build-essential libmagickcore-dev libmagic-dev libmagickwand-dev nginx

    echo "====== set locale ======"
    sudo update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8

    echo "====== set timezone ======"
    sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

    echo "====== setup NTP ======"
    sudo apt-get -y install ntp

    echo "====== install mysql ======"
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password passw0rd'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password passw0rd'
    sudo apt-get -y install mysql-server libmysqlclient-dev

    if [ ! -e '/home/vagrant/.rbenv' ]; then
      echo "====== Installing ruby ======"
      git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
      echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
      git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
      echo "reload shell..."
      source /home/vagrant/.bash_profile
      echo "installing ruby 2.2.3..."
      rbenv install 2.2.3
      echo "set ruby global..."
      rbenv global 2.2.3
      rbenv exec gem install bundler
      rbenv rehash
    fi
  SHELL
end
