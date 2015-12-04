#!/bin/bash

export OSS_USER=vagrant
export MYSQL_PASSWORD=passw0rd

sudo chmod 755 /tmp/ruby_env.sh
sudo chmod 755 /tmp/oss_env.sh

/tmp/ruby_env.sh
/tmp/oss_env.sh

mysql -uroot -p$MYSQL_PASSWORD mysql -e "create database openslideshare default character set 'utf8'"

sudo \rm /etc/nginx/sites-enabled/default
sudo tee /etc/nginx/sites-enabled/local.conf << 'EOS'
upstream unicorn {
  server unix:/tmp/unicorn.sock;
}

server {
  listen 80 default_server;
  server_name openslideshare;

  access_log /var/log/nginx/openslideshare_access.log;
  error_log /var/log/nginx/openslideshare_error.log;

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
