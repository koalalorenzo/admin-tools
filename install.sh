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
    return 1
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
    return 1
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
    return 1
}

# Installation functions

check_user(){
    if [ $SUDO_USER ]; then user=$SUDO_USER; else user=`whoami`; fi
    if [[ "$user" != "root" ]]; then
        echo_failure "The installation must be launched by root or via sudo command"
        exit 1;
    fi
}

check_os(){
    if [ "$UNAME" != "Linux" ] ; then
        echo_failure "Your OS is not supported! This script works on Linux (Ubuntu, Deban or Archlinux)"
        exit 1
    fi
}

check_if_already_installed(){
    if [ -f /var/domains/tools/install.sh ]; then 
        echo_failure "You already installed admin-tools. Use domain-manager-update to get a new version."
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
    install_something dialog
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
    if [ -f  /etc/admin-tools.settings.cfg ]; then
        dialog --title "Configuration already there" \
            --backtitle "admin-tools installations" \
            --yesno "The file /etc/admin-tools is already present. Would you like to replace it?" 7 60
        response=$?
        case $response in
           0) cp /var/domains/tools/settings.cfg /etc/admin-tools.settings.cfg;;
           1) echo "File not replaced.";;
           255) exit 1;;
        esac
    else
        cp /var/domains/tools/settings.cfg /etc/admin-tools.settings.cfg
    fi
    bash /var/domains/tools/domain-manager-fix-permissions

    export PATH=$PATH:/var/domains/tools/
    cat << EOF >> /etc/profile

## koalalorenzo's admin tools path:
PATH=$PATH:/var/domains/tools/
export PATH

EOF    
}

# The magic:
check_os
check_if_already_installed
install_dependencies
create_directories
install

if [ -f /usr/bin/beep ]; then
    beep -f 523.2 -l 138 -n -f 392.0 -l 138 -n -f 329.6 -l 138 -n -f 523.2 -l 138 -n -f 392.0 -l 138 -n -f 329.6 -l 138 -n -f 523.2 -l 828 -n -f 554.4 -l 138 -n -f 415.3 -l 138 -n -f 349.2 -l 138 -n -f 554.4 -l 138 -n -f 415.3 -l 138 -n -f 349.2 -l 138 -n -f 554.4 -l 828 -n -f 622.2 -l 138 -n -f 466.2 -l 138 -n -f 392.0 -l 138 -n -f 622.2 -l 138 -n -f 466.2 -l 138 -n -f 392.0 -l 138 -n -f 622.2 -l 414 -n -f 698.4 -l 138 -n -f 698.4 -l 138 -n -f 698.4 -l 138 -n -f 792 -l 1104
fi
