#!/usr/bin/env bash
set -eux

export DEBIAN_FRONTEND=noninteractive

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=751636
apt-get install libpam-systemd
