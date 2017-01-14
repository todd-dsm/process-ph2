#!/bin/bash
set -eux

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
adminHome='/home/admin'
backupDir="$adminHome/backup"
buildInfo='/etc/build-info'


###----------------------------------------------------------------------------
### MAIN
###----------------------------------------------------------------------------
### Set a time zone during the early stages of testing.
###---
#printf '\n%s\n' "Change Time Zone to 'US/Central'..."
printf '%s\n' "What time is it? "
date
#rm -f /etc/localtime
#ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
#ls -l /etc/localtime
#printf '%s\n' "Now what time is it? "
#date


###---
### Create Backup space
###---
printf '\n%s\n' "Creating backup space..."
if [[ ! -d "$backupDir" ]]; then
    mkdir -p "$backupDir"
fi

###---
### Create file for build info
###---
printf '\n%s\n' "Creating build tag..."
bTag="$(date '+%Y%m%d-%H%M%S')"
echo "Build date/time: $bTag" > "$buildInfo"

