#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# PURPOSE: In a NEW VPC, sets your DEFAULT Security Group to allow access
#          from your local internet Gateway. Only for new/first-time setups.
# -----------------------------------------------------------------------------
#    EXEC: ./access-sg.sh
# -----------------------------------------------------------------------------
#   NOTES:
# -----------------------------------------------------------------------------
#    TODO: 1) This script will breat in the event there is more than 1 AMI ID
#          2)
#          3)
# -----------------------------------------------------------------------------
#  AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#    DATE: 2017/01/15
# -----------------------------------------------------------------------------
#set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# Get Local Gateway Address
printf '\n%s\n' "Getting your local network Gateway IP address..."
declare currentIPAddress="$(dig +short myip.opendns.com @resolver1.opendns.com)"
if [[ -z "$currentIPAddress" ]]; then
    printf '%s\n' "OMG! You have NO IP ADDRESS!!!"
else
    printf '%s\n\n' "  Your current gateway address is: $currentIPAddress"
    declare myCIDRAddress="$currentIPAddress/32"
fi

# Get an SG Ingress IP if there is one
printf '%s\n' "Getting the status of your default VPC Ingress IP..."
locGWStatus="$(aws ec2 describe-security-groups                         \
    --query "(SecurityGroups[0].IpPermissions[1].IpRanges[0].CidrIp)"   \
    --output text)"

# Get default Security Group
printf '%s\n' "Getting the default SecurityGroups ID..."
defSGID="$(aws ec2 describe-security-groups                             \
    --query "(SecurityGroups[0].IpPermissions[0].UserIdGroupPairs[0].GroupId)" \
    --output text)"


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
###
###---
if [[ "$locGWStatus" = 'None' ]]; then
    printf '%s\n' """
    Authorizing your local gateway to:
        Access this AWS/VPC Security Group: $defSGID
        From this CIDR address:             $myCIDRAddress
    """
    aws ec2 authorize-security-group-ingress    \
        --group-id "$defSGID" --protocol tcp    \
        --port 22 --cidr "$myCIDRAddress"
else
    printf '%s\n' """
    These values are already set:
        This is your default Security Group: $defSGID
        This CIDR address accesses your VPC: $myCIDRAddress
    """
fi
