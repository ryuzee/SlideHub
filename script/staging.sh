#!/bin/bash

export OSS_USER=vagrant
export MYSQL_PASSWORD=passw0rd

sudo chmod 755 /tmp/ruby_env.sh
sudo chmod 755 /tmp/oss_env.sh

/tmp/ruby_env.sh
/tmp/oss_env.sh

sudo mkdir -p /opt/application
sudo chown -R $OSS_USER:`id -G -n $OSS_USER | awk '{print $1}'` /opt/application

if [ -e /tmp/environment ]; then
  sudo mv /tmp/environment /etc/environment
fi

if [ -e /tmp/id_rsa ]; then
  sudo mv /tmp/id_rsa /home/$OSS_USER/.ssh/id_rsa
  sudo chmod 600 /home/$OSS_USER/.ssh/id_rsa
fi

mysql -uroot -p$MYSQL_PASSWORD mysql -e "create database openslideshare default character set 'utf8'"

sudo \rm /etc/nginx/sites-enabled/default
sudo tee /etc/nginx/sites-enabled/local.conf << 'EOS'
upstream unicorn {
  server unix:/tmp/unicorn.sock;
}

server {
  listen 80 default_server;
  server_name slidehub;

  access_log /var/log/nginx/slidehub_access.log;
  error_log /var/log/nginx/slidehub_error.log;

  root /opt/application;

  client_max_body_size 100m;
  error_page 404 /404.html;
  error_page 500 502 503 504 /500.html;
  try_files $uri/index.html $uri @unicorn;

  location @unicorn {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_pass http://unicorn;
  }
}
EOS
sudo service nginx restart
