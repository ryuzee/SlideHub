#!/bin/bash

set -e
RUBY_VERSION=2.3.1


echo "====== Installing packages via apt ======"
sudo apt-get update
sudo apt-get -y install language-pack-ja wget curl zip unzip git sqlite3 libsqlite3-dev
sudo apt-get -y install build-essential libssl-dev libreadline-dev libmagickcore-dev libmagic-dev libmagickwand-dev graphviz nginx

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

if [ ! -e "/home/$OSS_USER/.rbenv" ]; then
  echo "====== Installing ruby ======"
  sudo -H -u $OSS_USER -s bash -c "git clone https://github.com/sstephenson/rbenv.git /home/$OSS_USER/.rbenv"
  sudo -H -u $OSS_USER -s bash -c "echo 'export PATH=/home/$OSS_USER/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /home/$OSS_USER/.bash_profile"
  sudo -H -u $OSS_USER -s bash -c "echo 'eval \"\$(rbenv init -)\"' >> /home/$OSS_USER/.bash_profile"
  sudo -H -u $OSS_USER -s bash -c "git clone https://github.com/sstephenson/ruby-build.git /home/$OSS_USER/.rbenv/plugins/ruby-build"
  echo "reload shell..."
  sudo -H -u $OSS_USER -s bash -c "source /home/$OSS_USER/.bash_profile"
  echo "installing ruby $RUBY_VERSION..."
  sudo -H -u $OSS_USER -s bash -c "source /home/$OSS_USER/.bash_profile && rbenv install $RUBY_VERSION"
  echo "set ruby global..."
  sudo -H -u $OSS_USER -s bash -c "source /home/$OSS_USER/.bash_profile && rbenv global $RUBY_VERSION"
  sudo -H -u $OSS_USER -s bash -c "source /home/$OSS_USER/.bash_profile && rbenv exec gem install bundler"
  sudo -H -u $OSS_USER -s bash -c "source /home/$OSS_USER/.bash_profile && rbenv rehash"
fi
