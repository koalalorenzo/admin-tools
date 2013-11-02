#!/bin/bash

sudo mkdir -p /var/domains/sites
sudo mkdir -p /var/domains/confs
sudo mkdir -p /var/domains/backups
sudo mkdir -p /var/domains/backups/torrents 
#I Should use one line with /backups/torrents, but is cool-er like this :P

sudo apt-get install git mercurial fail2ban 
sudo apt-get install apache2 libapache2-mod-wsgi libapache2-mod-proxy-html
sudo apt-get install mysql-server phpmyadmin
sudo apt-get install transmission-cli transmission-daemon

sudo service transmission-daemon stop
sudo echo 'manual' | sudo tee /etc/init/transmission-daemon.override

sudo git clone https://github.com/koalalorenzo/admin-tools.git /var/domains/tools
sudo bash /var/domains/tools/domain-manager-fix-permissions

sudo cp /var/domains/tools/settings.cfg /etc/admin-tools.settings.cfg

export PATH=$PATH:/var/domains/tools/
cat << EOF >> /etc/profile

## koalalorenzo's admin tools path:
PATH=$PATH:/var/domains/tools/
export PATH

EOF
