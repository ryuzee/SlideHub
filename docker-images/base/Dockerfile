FROM --platform=linux/amd64 ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install wget curl zip unzip git sqlite3 libsqlite3-dev build-essential libssl-dev libreadline-dev imagemagick libmagickcore-dev libmagic-dev libmagickwand-dev graphviz nginx language-pack-ja ntp libmysqlclient-dev supervisor unoconv poppler-utils mupdf-tools xvfb fonts-vlgothic fonts-mplus fonts-migmix && update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN echo "export PATH=/root/.rbenv/shims:/root/.rbenv/bin:/root/.nodebrew/current/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /root/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
ENV PATH /root/.rbenv/bin:$PATH
ENV RAILS_ROOT /opt/application/current
RUN bash -c "source /root/.bashrc && rbenv install 3.1.6"
RUN bash -c "source /root/.bashrc && rbenv global 3.1.6"
RUN bash -c "source /root/.bashrc && rbenv exec gem install bundler -v 1.17.3"
RUN bash -c "source /root/.bashrc && rbenv rehash"

RUN curl -L git.io/nodebrew | perl - setup
ENV PATH /root/.nodebrew/current/bin:$PATH
RUN /root/.nodebrew/current/bin/nodebrew install v12.16.1
RUN /root/.nodebrew/current/bin/nodebrew use v12.16.1
RUN npm install --g yarn

COPY supervisor.conf /etc/supervisor.conf

# RUN apt-get -y install libxmlsec1=1.2.25-1 libxmlsec1-openssl=1.2.25-1
# RUN apt-mark hold libxmlsec1 libxmlsec1-openssl

RUN apt-get -y autoremove && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/mesg n || true/tty -s \&\& mesg n/' /root/.profile

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]