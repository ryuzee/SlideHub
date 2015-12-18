#!/bin/bash

export OSS_USER=vagrant
export MYSQL_PASSWORD=passw0rd

sudo chmod 755 /tmp/ruby_env.sh
sudo chmod 755 /tmp/oss_env.sh

/tmp/ruby_env.sh
/tmp/oss_env.sh

mysql -uroot -p$MYSQL_PASSWORD mysql -e "create database openslideshare default character set 'utf8'"
mysql -uroot -p$MYSQL_PASSWORD mysql -e "create database test_openslideshare default character set 'utf8'"
mysql -uroot -p$MYSQL_PASSWORD mysql -e "grant all on *.* to 'root'@'*' identified by 'passw0rd'"

sudo sed -i "s/^bind-address.*//" /etc/mysql/my.cnf
sudo service mysql restart



