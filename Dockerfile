FROM ubuntu:14.04
MAINTAINER ryuzee

RUN apt-get update && apt-get -y install language-pack-ja wget curl zip unzip git sqlite3 libsqlite3-dev build-essential libssl-dev libreadline-dev libmagickcore-dev libmagic-dev libmagickwand-dev graphviz nginx language-pack-ja ntp libmysqlclient-dev && update-locale LANGUAGE=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN echo "export PATH=/root/.rbenv/shims:/root/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /root/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
ENV PATH /root/.rbenv/bin:$PATH
ENV RAILS_ROOT /opt/application/current
RUN bash -c "source /root/.bashrc && rbenv install 2.2.3"
RUN bash -c "source /root/.bashrc && rbenv global 2.2.3"
RUN bash -c "source /root/.bashrc && rbenv exec gem install bundler"
RUN bash -c "source /root/.bashrc && rbenv rehash"

RUN apt-get install -y unoconv imagemagick xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix supervisor libmagickwand-dev
RUN cd /tmp && wget "http://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/ja/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_ja.tar.gz" --tries 3 -O /tmp/openoffice.tar.gz && tar xvfz /tmp/openoffice.tar.gz && cd ja/DEBS && sudo dpkg -i *.deb

RUN mkdir -p /opt/application/current/
WORKDIR /opt/application/current/

COPY Gemfile /opt/application/current/
COPY Gemfile.lock /opt/application/current/

RUN /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bundle install --without development test'

RUN apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

COPY . /opt/application/current
RUN chmod 755 /opt/application/current/script/oss_docker_batchjob.sh
COPY script/oss_docker_supervisor.conf /etc/supervisor.conf

RUN bash -l -c 'DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile'

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
