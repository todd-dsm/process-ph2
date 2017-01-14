#!/usr/bin/env bash
# QnD script to reset test env

# kill vagrant box
vagrant halt && vagrant destroy -f

# unload it from the local registry
echo -e "Dumping packer boxes from the local Vagrant registry..."
vagrant box remove jessie

# display boxes
vagrant box list

echo -e "\n"
