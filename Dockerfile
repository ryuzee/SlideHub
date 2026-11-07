# syntax=docker/dockerfile:1
#
# 本番用（既定）と開発用（--target development）のイメージを作る。
#
# - base        : 動かすのに要るものだけを入れた土台（公式の Ruby イメージ）
# - build       : gem と JavaScript のパッケージを入れ、CSS・JavaScript をビルドする
# - production  : base に、build で作った gem とアプリを移す。コンパイラや yarn は入らない
#                 （Node.js は、プレイヤーの JavaScript を terser で圧縮するために node だけ入れる）
# - development : build に、開発用の gem と mailcatcher を足す（docker-compose.yml で使う）
#
# スライドの変換に使うのは mutool（PDF→JPEG）と pdftotext（ページの文字）と ImageMagick（サムネイル）
ARG RUBY_VERSION=3.4.12
ARG NODE_VERSION=24

FROM node:${NODE_VERSION}-trixie-slim AS node

FROM ruby:${RUBY_VERSION}-slim-trixie AS base

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    RAILS_ROOT=/opt/application/current \
    BUNDLE_PATH=/usr/local/bundle

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       imagemagick mupdf-tools poppler-utils fonts-vlgothic \
       libmariadb3 libyaml-0-2 tzdata supervisor curl ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*

# bash -l で開いても、gem で入れたコマンド（/usr/local/bundle/bin）が使えるようにする
RUN echo 'export PATH="/usr/local/bundle/bin:$PATH"' > /etc/profile.d/bundle_path.sh

RUN gem install bundler -v 4.0.24

WORKDIR /opt/application/current

FROM base AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential pkg-config git default-libmysqlclient-dev libmagickwand-dev libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && npm install -g yarn \
    && node -v && yarn -v

# 本番では開発用・テスト用の gem を入れない。開発用のイメージでは空にして全部入れる。
# 開発用では、gem を docker-compose.yml のボリュームと同じ場所（/bundle）に入れる
ARG BUNDLE_WITHOUT="development:test:doc"
ARG BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    BUNDLE_PATH=${BUNDLE_PATH}

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf "${BUNDLE_PATH}/cache"

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN chmod 755 script/*.sh

# CSS・JavaScript をビルドし、public/assets にダイジェスト付きで置く。
# ビルド時は DB が無いので、ros-apartment の起動時テナント初期化を無効にする
RUN APARTMENT_DISABLE_INIT=1 SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile

FROM build AS development

# 開発用のメールの受け口。docker-compose.yml がアプリの gem 用に別の場所をつなぐので、
# 見えなくならないよう専用の場所に入れ、/usr/local/bin から呼べるようにする
RUN gem install mailcatcher -v 0.10.0 --install-dir /opt/mailcatcher --no-document \
    && printf '#!/bin/sh\nexport GEM_HOME=/opt/mailcatcher GEM_PATH=/opt/mailcatcher\nexec /opt/mailcatcher/bin/mailcatcher "$@"\n' > /usr/local/bin/mailcatcher \
    && chmod 755 /usr/local/bin/mailcatcher

COPY script/oss_docker_supervisor_dev.conf /etc/supervisor.conf

EXPOSE 3000 1080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]

# 何も指定しないでビルドしたときは本番用（最後の段）になる
FROM base AS production

# プレイヤーの JavaScript は、表示するときに terser で圧縮する（PlayerScript）。
# terser は ExecJS を通して Node.js で動くので、node だけは本番にも入れる（npm や yarn は入れない）
COPY --from=node /usr/local/bin/node /usr/local/bin/node

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --exclude=node_modules --exclude=tmp/cache /opt/application/current /opt/application/current
ENV BUNDLE_WITHOUT="development:test:doc"

# JavaScript を動かせることを、ビルドの時点で確かめる（動かせないとプレイヤーが 500 になる）
RUN bundle exec ruby -e 'require "terser"; Terser.new.compile("var a = 1;")'

COPY script/oss_docker_supervisor.conf /etc/supervisor.conf

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
