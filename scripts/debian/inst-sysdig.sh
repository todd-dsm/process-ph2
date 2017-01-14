#!/usr/bin/env bash
# PURPOSE: Install sysdig on the system.
#     URL: http://www.sysdig.org/install/
#   GUIDE: http://www.sysdig.org/wiki/sysdig-user-guide/
set -eux

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
myProg='Sysdig'
keyGPG='https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public'
backPortURL='http://download.draios.com/stable/deb/draios.list'
backPortFile='/etc/apt/sources.list.d/draios.list'


###----------------------------------------------------------------------------
### MAIN
###----------------------------------------------------------------------------
### Import the keys
###---
curl -s "$keyGPG" | apt-key add -


###---
### Configure Backports
###---
printf '\n\n%s\n' "Creating $myProg backports file..."
curl -s -o "$backPortFile" "$backPortURL"

printf '\n\n%s\n' "The $myProg backports file:"
cat "$backPortFile"


###---
### Install dependencies, et al.
###---
printf '\n\n%s\n' "Installing dependencies..."
apt-get update
apt-get -y install "linux-headers-$(uname -r)"


###---
### Install the program
###---
printf '\n\n%s\n' "Installing $myProg..."
apt-get -y install sysdig

exit 0
