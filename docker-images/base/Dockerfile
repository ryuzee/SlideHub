FROM ryuzee/ruby:latest
MAINTAINER ryuzee

RUN apt-get update && apt-get install -y unoconv xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix libmagickwand-dev
RUN cd /tmp && wget "http://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/ja/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_ja.tar.gz" --tries 3 -O /tmp/openoffice.tar.gz && tar xvfz /tmp/openoffice.tar.gz && cd ja/DEBS && sudo dpkg -i *.deb

