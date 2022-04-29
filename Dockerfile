FROM ryuzee/slidehub-base:20220429
MAINTAINER ryuzee

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install'

COPY package.json /opt/application/current/
COPY yarn.lock /opt/application/current/
RUN yarn

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/*.sh
COPY script/oss_docker_supervisor.conf /etc/supervisor.conf

RUN bash -l -c 'OSS_SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake assets:precompile'

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
