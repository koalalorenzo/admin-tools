#!/bin/bash
# See: http://projects.setale.me/admin-tools/
# Version 2

UNAME=$(uname)
set -e
set -u

## REQUIREMENTS
# required variables
BOOTUP=color
RES_COL=70
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
 
# Messages
echo_failure() {
    echo -n $1
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
    echo -n $"FAILED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo ""
}

echo_warning() {
    echo -n $1
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
    echo -n $"WARNING"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo ""
}

echo_success() {
    echo -n $1
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
    echo -n $"DONE"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo ""
}

check_user(){
    if [ $SUDO_USER ]; then user=$SUDO_USER; else user=`whoami`; fi
    if [[ "$user" != "root" ]]; then
        echo_failure "The installation must be launched by root or via sudo command"
        exit 1;
    fi
}

# Installation functions

check_os(){
    if [ "$UNAME" != "Linux" ] ; then
        echo_failure "Your OS is not supported!"
        echo "This script works on Linux (Ubuntu, Deban or Archlinux)"
        exit 1
    fi
}

check_if_already_installed(){
    if [ -f /var/domains/tools/install.sh ]; then 
        echo_failure "You already installed admin-tools."
        echo "Use domain-manager-update to get a new version."
        exit 1
    fi;
}

install_something(){
    if [ -f  /usr/bin/apt-get ]; then
        apt-get --yes install $1
    elif [ -f  /usr/bin/pacman ]; then
        pacman -S $1
    fi
}

install_dependencies(){
    install_something beep
    install_something apache2
    install_something libapache2-mod-wsgi
    install_something libapache2-mod-proxy-html
    install_something mysql-server
    install_something phpmyadmin
    install_something transmission-cli
    install_something transmission-daemon
}

create_directories(){
    mkdir -p /var/domains/sites
    mkdir -p /var/domains/confs
    mkdir -p /var/domains/backups
    mkdir -p /var/domains/backups/torrents  
}

install(){
    git clone https://github.com/koalalorenzo/admin-tools.git /var/domains/tools
}

configure(){
    export PATH=$PATH:/var/domains/tools/
    echo "" >> /etc/profile
    echo "## koalalorenzo's admin tools path:" >> /etc/profile
    echo "PATH=$PATH:/var/domains/tools/" >> /etc/profile
    echo "export PATH" >> /etc/profile

    if [ -f  /etc/admin-tools.settings.cfg ]; then
        datetime_now=$(date +%Y%m%d%M%S)
        cp /etc/admin-tools.settings.cfg /etc/admin-tools.settings.old.$datetime_now.cfg
        cp /var/domains/tools/settings.cfg /etc/admin-tools.settings.cfg
        echo_warning "/var/domains/tools/settings.cfg replaced."
        echo "The old file is here: /etc/admin-tools.settings.old.${datetime_now}.cfg"
    else
        cp /var/domains/tools/settings.cfg /etc/admin-tools.settings.cfg
    fi
}

finish(){
    if [ -f /usr/bin/beep ]; then
        beep -f 523.2 -l 138 -n -f 392.0 -l 138 -n -f 329.6 -l 138 -n -f 523.2 -l 138 -n -f 392.0 -l 138 -n -f 329.6 -l 138 -n -f 523.2 -l 828 -n -f 554.4 -l 138 -n -f 415.3 -l 138 -n -f 349.2 -l 138 -n -f 554.4 -l 138 -n -f 415.3 -l 138 -n -f 349.2 -l 138 -n -f 554.4 -l 828 -n -f 622.2 -l 138 -n -f 466.2 -l 138 -n -f 392.0 -l 138 -n -f 622.2 -l 138 -n -f 466.2 -l 138 -n -f 392.0 -l 138 -n -f 622.2 -l 414 -n -f 698.4 -l 138 -n -f 698.4 -l 138 -n -f 698.4 -l 138 -n -f 792 -l 1104
    fi
    echo_success "Installation completed"
}

# The magic:
check_os
check_if_already_installed
install_dependencies
create_directories
install
configure
bash /var/domains/tools/domain-manager-fix-permissions
finish