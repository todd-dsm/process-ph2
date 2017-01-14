#!/usr/bin/env bash
set -eux

export DEBIAN_FRONTEND=noninteractive
adminHome='/home/admin'
backupDir="$adminHome/backup"
sshdConf="/etc/ssh/sshd_config"

### Backup original configuration file
cp -pv "$sshdConf" "$backupDir"

# ensure that there is a trailing newline before attempting to concatenate
sed -i -e '$a\' "$sshdConf"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$sshdConf"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$sshdConf"
else
    echo "$USEDNS" >>"$sshdConf"
fi

GSSAPI="GSSAPIAuthentication no"
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$sshdConf"; then
    sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$sshdConf"
else
    echo "$GSSAPI" >>"$sshdConf"
fi
