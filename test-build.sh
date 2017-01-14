#!/usr/bin/env bash
# QnD scipt to build new AMIs with packer and Terraform them up for testing.
set -x

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
export PACKER_NO_COLOR='false'
packerDefs='debian-8.6-ami.json'
pCMDS=('validate' 'inspect' 'build')


###----------------------------------------------------------------------------
### Functions
###----------------------------------------------------------------------------
preemie()   {
    echo -e "\n\n    Abort! Abort!    \n\n"
    exit 1
}

tellPacker()    {
    pCMD="$1"
    packer "$pCMD"  "$packerDefs"
    if [[ $? -ne '0' ]]; then
        preemie
    else
        return
    fi
}

tfCheck()   {
    if [[ $? -ne 0 ]]; then
        preemie
    else
        return
    fi
}

###----------------------------------------------------------------------------
### PACKER: Build the AMI
###----------------------------------------------------------------------------
#date
#printf '%s\n'
#for commands in "${pCMDS[@]}"; do
#    printf '%s\n\n' "  ${commands^}! "
#    tellPacker "$commands" '2>&1 > /tmp/packer.out'
#done
#date


###----------------------------------------------------------------------------
### PACKER: Deploy an Instance from the AMI
###----------------------------------------------------------------------------
### Get your A record
###---
date
currentIPAddress="$(dig +short myip.opendns.com @resolver1.opendns.com)"
if [[ -z "$currentIPAddress" ]]; then
    printf '%s\n' "OMG! You have NO IP ADDRESS!!!"
    preemie
fi
echo "myIPAddress=$currentIPAddress/32"

###---
### Validate the Terraform files (current working directory)
###---
terraform validate
tfCheck


###---
###
###---
terraform plan -var "myIPAddress=$currentIPAddress/32"
tfCheck


###---
### Build it!
###---
terraform apply -var "myIPAddress=$currentIPAddress/32"

date

echo -e ""
echo "Ready for Testing! "
echo -e "\n"
