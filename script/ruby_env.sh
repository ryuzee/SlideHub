#!/bin/bash

set -e
RUBY_VERSION=2.2.3
MYSQL_PASSWORD=passw0rd

echo "====== Installing packages via apt ======"
sudo apt-get update
sudo apt-get -y install language-pack-ja wget curl zip unzip git sqlite3 libsqlite3-dev
sudo apt-get -y install build-essential libmagickcore-dev libmagic-dev libmagickwand-dev graphviz nginx

echo "====== set locale ======"
sudo apt-get install -y language-pack-ja
sudo update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8

echo "====== set timezone ======"
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

echo "====== setup NTP ======"
sudo apt-get -y install ntp

echo "====== install mysql ======"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
sudo apt-get -y install mysql-server libmysqlclient-dev

if [ ! -e '/home/`whoami`/.rbenv' ]; then
  echo "====== Installing ruby ======"
  git clone https://github.com/sstephenson/rbenv.git /home/`whoami`/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/`whoami`/.bash_profile
  echo 'eval "$(rbenv init -)"' >> /home/`whoami`/.bash_profile
  git clone https://github.com/sstephenson/ruby-build.git /home/`whoami`/.rbenv/plugins/ruby-build
  echo "reload shell..."
  source /home/`whoami`/.bash_profile
  echo "installing ruby $RUBY_VERSION..."
  rbenv install $RUBY_VERSION
  echo "set ruby global..."
  rbenv global $RUBY_VERSION
  rbenv exec gem install bundler
  rbenv rehash
fi
