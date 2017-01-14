#!/usr/bin/env bash
set -eux

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
grubConf='/etc/default/grub'
#backPortFile='/etc/apt/sources.list.d/docker.list'
#key="58118E89F3A912897C070ADBF76221572C52609D"
#keyServers=('ha.pool.sks-keyservers.net' 'pgp.mit.edu' 'keyserver.ubuntu.com')

###----------------------------------------------------------------------------
### MAIN
###----------------------------------------------------------------------------
### Prep OS for Docker install; configure GRUB
###---
printf '\n\n%s\n' "Configuring Grub..."
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/quiet/cgroup_enable=memory swapaccount=1/g' "$grubConf"

### Gen a new grub2 config
update-grub

###----------------------------------------------------------------------------
### Install Docker - Use the official Docker install script.
### Their script accounts for flakey GPG key server behavior.
###----------------------------------------------------------------------------
wget -qO- https://get.docker.com/ | sh


####---
#### Configure Backports
####---
#printf '\n\n%s\n' "Creating Docker backports file..."
#cat <<EOF > "$backPortFile"
#deb https://apt.dockerproject.org/repo debian-jessie main
#EOF
#
#printf '\n\n%s\n' "The Docker backports file:"
#cat "$backPortFile"
#
####---
#### Import the keys for the current docker apt repository
#### The transport for the keys is flakey for more than 1 reason. Try them all
#### until 1 is successfully transferred.
#### URL: https://goo.gl/JnNrJC
####---
#printf '%s\n' "Adding Docker GPG keys..."
#for key_server in "${keyServers[@]}"; do
#    printf '%s\n\n' "  attempting to pull keys from $key_server"
#    apt-key adv --keyserver "hkp://$key_server:80" --recv-keys "$key"
#    if [[ $? -ne 0 ]]; then
#        continue
#        printf '%s\n' "Bad  key server: $key_server"
#    else
#        printf '%s\n' "Good key server: $key_server"
#        break
#    fi
#done
#
#
####---
#### install Docker, et al
####---
#apt-get update
#apt-cache policy docker-engine
#apt-get -y --force-yes install docker-engine


###---
### install docker-compose
###---
printf '\n\n%s\n' "Pulling the latest docker-compose..."
/usr/bin/pip install docker-compose


###---
### finalize system work
###---
### Add user to docker group
printf '\n\n%s\n' "Adding user to the docker group..."
usermod -aG docker admin

### Enable and Init Docker
printf '\n\n%s\n' "Enabling Docker..."
systemctl enable docker
#systemctl start docker
systemctl -l status docker

exit 0
