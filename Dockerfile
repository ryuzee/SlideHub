FROM ryuzee/ruby:latest
MAINTAINER ryuzee

RUN apt-get update && apt-get install -y unoconv xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix libmagickwand-dev
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

RUN bash -l -c 'OSS_SECRET_KEY_BASE=dummy DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile'

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
