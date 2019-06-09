FROM ryuzee/slidehub-base:20190501
MAINTAINER ryuzee

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install --deployment --without development test'

COPY package.json /opt/application/current/
COPY yarn.lock /opt/application/current/

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn
RUN yarn

RUN apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/*.sh
COPY script/oss_docker_supervisor.conf /etc/supervisor.conf

RUN bash -l -c 'OSS_SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake assets:precompile'

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
