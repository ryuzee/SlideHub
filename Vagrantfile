# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "opscode-ubuntu-14.04"
  # config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 3000, host: 3001
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  config.vm.synced_folder ".", "/home/vagrant/application"
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  config.vm.provision "shell", :privileged => false, inline: <<-SHELL
    echo "====== Installing packages via apt ======"
    sudo apt-get update
    sudo apt-get -y install language-pack-ja wget curl zip unzip git
    sudo apt-get -y install build-essential

    echo "====== set locale ======"
    sudo update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8

    echo "====== set timezone ======"
    sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

    echo "====== install mysql ======"
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password passw0rd'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password passw0rd'
    sudo apt-get -y install mysql-server

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
