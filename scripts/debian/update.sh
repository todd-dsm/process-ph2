#!/usr/bin/env bash
set -eux

export DEBIAN_FRONTEND=noninteractive
arch="$(uname -r)"

### Output list of installed packages


# package removals
apt-get -y --purge remove vim-tiny nano

### Update all packages
apt-get update

# install Linux kernel build stuff
apt-get -y upgrade linux-image-"${arch##*-}"
apt-get -y install "linux-headers-$arch"

# sysadmin utils
apt-get -y install strace tree curl bzip2
# dev utils / python pip
apt-get install -y unattended-upgrades vim git python-pip

# TODO update the find package db
#apt-get -y install apt-find
#apt-find update

if [ -d /etc/init ]; then
    # update package index on boot
    cat <<EOF >/etc/init/refresh-apt.conf;
description "update package index"
start on networking
task
exec /usr/bin/apt-get update
EOF
fi
