#!/bin/sh

cd `dirname $0`
cd ..

bash -l -c 'bundle exec rake db:migrate RAILS_ENV=production'
bash -l -c 'bundle exec rake db:seed RAILS_ENV=production'

/usr/bin/supervisord -c /etc/supervisor.conf
