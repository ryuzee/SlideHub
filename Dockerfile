FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install wget curl zip unzip git sqlite3 libsqlite3-dev build-essential libssl-dev libreadline-dev imagemagick libmagickcore-dev libmagickwand-dev graphviz nginx language-pack-ja ntp libmysqlclient-dev libyaml-dev supervisor unoconv poppler-utils mupdf-tools xvfb fonts-vlgothic fonts-mplus fonts-migmix && update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN echo "export PATH=/root/.rbenv/shims:/root/.rbenv/bin:/root/.nodebrew/current/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /root/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
ENV PATH /root/.rbenv/bin:$PATH
ENV RAILS_ROOT /opt/application/current
RUN bash -c "source /root/.bashrc && rbenv install 3.4.12"
RUN bash -c "source /root/.bashrc && rbenv global 3.4.12"
RUN bash -c "source /root/.bashrc && rbenv exec gem install bundler -v 4.0.24"
RUN bash -c "source /root/.bashrc && rbenv rehash"

ENV PATH /root/.nodebrew/current/bin:$PATH
# nodebrewはArchive::Tarで展開するが、Ubuntuの patched Archive::Tar が相対シンボリック
# リンクの展開を拒否するためnpm等が入らない。公式tarballをGNU tarで展開する。
ARG NODE_VERSION=v22.23.4
RUN mkdir -p /root/.nodebrew/node \
    && curl -fsSL -o /tmp/node.tar.gz "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz" \
    && tar -xzf /tmp/node.tar.gz -C /root/.nodebrew/node \
    && mv "/root/.nodebrew/node/node-${NODE_VERSION}-linux-x64" "/root/.nodebrew/node/${NODE_VERSION}" \
    && ln -sfn "/root/.nodebrew/node/${NODE_VERSION}" /root/.nodebrew/current \
    && rm -f /tmp/node.tar.gz \
    && node -v && npm -v \
    && npm install --g yarn \
    && yarn -v

RUN apt-get -y autoremove && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/mesg n || true/tty -s \&\& mesg n/' /root/.profile

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN bash -l -c 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install'

# 開発環境専用の処理をオプション化
ARG INSTALL_MAILCATCHER=false
RUN bash -l -c "if [ \"$INSTALL_MAILCATCHER\" = \"true\" ]; then gem install mailcatcher -v 0.10.0; fi"

COPY package.json /opt/application/current/
COPY yarn.lock /opt/application/current/
RUN yarn

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/*.sh

# supervisor.confの切り替え
ARG SUPERVISOR_CONF=script/oss_docker_supervisor.conf
COPY $SUPERVISOR_CONF /etc/supervisor.conf

# yarn build / yarn build:css (esbuild) を実行し、その結果を public/assets にダイジェスト付きで配置する。
# ビルド時は DB が無いので、ros-apartment の起動時テナント初期化を無効にする
RUN bash -l -c 'APARTMENT_DISABLE_INIT=1 SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile'

# ポートの切り替え
ARG EXPOSE_PORTS="3000"
EXPOSE ${EXPOSE_PORTS}

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
