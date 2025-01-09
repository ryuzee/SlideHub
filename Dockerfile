FROM --platform=linux/amd64 ryuzee/slidehub-base:2025010902

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install'

# 開発環境専用の処理をオプション化
ARG INSTALL_MAILCATCHER=false
RUN bash -l -c "if [ \"$INSTALL_MAILCATCHER\" = \"true\" ]; then gem install mailcatcher -v 0.6.5; fi"

COPY package.json /opt/application/current/
COPY yarn.lock /opt/application/current/
RUN yarn

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/*.sh

# supervisor.confの切り替え
ARG SUPERVISOR_CONF=script/oss_docker_supervisor.conf
COPY $SUPERVISOR_CONF /etc/supervisor.conf

RUN bash -l -c 'OSS_SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake assets:precompile'

# ポートの切り替え
ARG EXPOSE_PORTS="3000"
EXPOSE ${EXPOSE_PORTS}

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
