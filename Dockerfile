FROM ryuzee/openslideshare-v2-base
MAINTAINER ryuzee

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install --without development test'

RUN apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/oss_docker_batchjob.sh
COPY script/oss_docker_supervisor.conf /etc/supervisor.conf

RUN bash -l -c 'OSS_SECRET_KEY_BASE=dummy DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile'

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
