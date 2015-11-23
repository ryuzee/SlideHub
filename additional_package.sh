#!/bin/bash

set -e
sudo apt-get update
sudo apt-get install -y unoconv imagemagick xpdf xvfb fonts-vlgothic fonts-mplus fonts-migmix supervisor
sudo apt-get install libmagickwand-dev

cd /tmp
wget "http://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/ja/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_ja.tar.gz" --tries 3 -O /tmp/openoffice.tar.gz
tar xvfz /tmp/openoffice.tar.gz && cd ja/DEBS && sudo dpkg -i *.deb

sudo tee /etc/supervisor/conf.d/01_unoconv.conf <<EOF >/dev/null
[program:xvfb]
command=Xvfb :1
user=vagrant
autostart=true
autorestart=true
stdout_logfile=/var/log/xvfb.log
redirect_stderr=true

[program:unoconv]
command=unoconv --listener
user=vagrant
autostart=true
autorestart=true
stdout_logfile=/var/log/unoconv.log
redirect_stderr=true
environment=DISPLAY=:1
stopasgroup=true
EOF
