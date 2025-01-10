FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install wget curl zip unzip git sqlite3 libsqlite3-dev build-essential libssl-dev libreadline-dev imagemagick libmagickcore-dev libmagic-dev libmagickwand-dev graphviz nginx language-pack-ja ntp libmysqlclient-dev supervisor unoconv poppler-utils mupdf-tools xvfb fonts-vlgothic fonts-mplus fonts-migmix && update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN echo "export PATH=/root/.rbenv/shims:/root/.rbenv/bin:/root/.nodebrew/current/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /root/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
ENV PATH /root/.rbenv/bin:$PATH
ENV RAILS_ROOT /opt/application/current
RUN bash -c "source /root/.bashrc && rbenv install 2.7.6"
RUN bash -c "source /root/.bashrc && rbenv global 2.7.6"
RUN bash -c "source /root/.bashrc && rbenv exec gem install bundler -v 1.17.3"
RUN bash -c "source /root/.bashrc && rbenv rehash"

RUN curl -L git.io/nodebrew | perl - setup
ENV PATH /root/.nodebrew/current/bin:$PATH
RUN /root/.nodebrew/current/bin/nodebrew install v18.19.1
RUN /root/.nodebrew/current/bin/nodebrew use v18.19.1
RUN npm install --g yarn

RUN apt-get -y autoremove && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/mesg n || true/tty -s \&\& mesg n/' /root/.profile

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN bash -l -c 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install'

# 開発環境専用の処理をオプション化
ARG INSTALL_MAILCATCHER=false
RUN bash -l -c "if [ \"$INSTALL_MAILCATCHER\" = \"true\" ]; then gem install mailcatcher -v 0.6.5; fi"

ENV NODE_OPTIONS=--openssl-legacy-provider
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
