#!/bin/bash

sudo mkdir -p /var/domains/sites
sudo mkdir -p /var/domains/confs
sudo mkdir -p /var/domains/backups
sudo mkdir -p /var/domains/backups/torrents 
#I Should use one line with /backups/torrents, but is cool-er like this :P


sudo apt-get install mercurial fail2ban apache2 libapache2-mod-wsgi libapache2-mod-proxy-html
sudo apt-get install mysql-server phpmyadmin
sudo apt-get install transmission-cli transmission-daemon

sudo service transmission-daemon stop
sudo echo 'manual' | sudo tee /etc/init/transmission-daemon.override

sudo hg clone http://hg.setale.me/admin-tools /var/domains/tools
sudo bash /var/domains/tools/domain-manager-fix-permissions