#!/usr/bin/env bash
# shellcheck disable=SC2086,SC1091
# QnD scipt to build new Amazon Machine Image.
# EXEC: ./build-ami.sh debian-8.6-ami.json
set -x

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
source vars-build

### Determine Latest ImageId
# assign the result of the script to a variable
#declare reqdImageId="$(eval scripts/aws-tools/find-latest-amis.sh \
#    -r "$AWS_REGION" -n jessie -d debian | tail -1)"
###----------------------------------------------------------------------------
#export  PACKER_NO_COLOR='false'
declare packerFile="$1"
declare statusCount='0'
declare defsValBld="-var myAWSRegion=$AWS_REGION $packerFile"

# Packer may grow to include more testing in the future; form the arrays:
declare -A subArgs;                declare -a subCMDs;
subArgs["validate"]="$defsValBld"; subCMDs+=( "validate" )
subArgs["inspect"]="$packerFile";  subCMDs+=( "inspect" )


###----------------------------------------------------------------------------
### Functions
###----------------------------------------------------------------------------
### if a step fails there's no need to go any further
failMsg()   {
    echo -e "\n\n    Abort! Abort!    \n\n"
    exit 1
}

# Increase statusCount by 1
passJob() {
    statusCount="$((statusCount+1))"
    #printf '%s\n' "  \$statusCount: $statusCount"
}

# Decrease statusCount by 1
failJob() {
    statusCount="$((statusCount-1))"
    failMsg
    #printf '%s\n' "  \$statusCount: $statusCount"
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Find our current AMI
###---
declare currentAMI="$(eval scripts/aws-tools/find-latest-amis.sh \
    -n base -d self | tail -1)"

# Announce the plan:
if [[ -z "$currentAMI" ]]; then
    printf '\n%s\n' """
        There is no current AMI fitting this description. Building new...
    """
else
    printf '\n%s\n' """
        The current image $currentAMI is going to be replaced.
        These are the details:
    """
    # Display AMI details
    aws ec2 describe-images --image-ids "$currentAMI"
fi


###---
### Verify the ImageId fits the pattern
###---
for i in "${!subCMDs[@]}"; do
    # Leverage array index to order associative array params/values
    printf '\n%s\n' "${subCMDs[$i]^}..."
    # Take advantage of word-splitting; do NOT quote the variables
    if ! packer ${subCMDs[$i]} ${subArgs[${subCMDs[$i]}]}; then
        printf '%s\n' "  The packer ${subCMDs[$i]} step failed."
        failJob
    else
        printf '%s\n' "  The packer ${subCMDs[$i]} step passed."
        passJob
    fi
done


###---
### If we made it this far, we're ready; build the VM.
###---
if [[ "$statusCount" -ne '2' ]]; then
    failMsg
else
    printf '\n%s\n' "Building the AMI..."
    # Take advantage of word-splitting; do NOT quote the variable
    if ! packer build $defsValBld; then
        printf '\n%s\n' "  The packer build step failed."
        failMsg
    else
        ### Display new AMI stats
        declare newAMI="$(eval scripts/aws-tools/find-latest-amis.sh \
            -n base -d self | tail -1)"
        ### Announce the changes:
        printf '\n%s\n' """
            The packer build step passed.
            All future builds will be based on the new image: $newAMI
            These are the details:
            """
        ### Display AMI details
        aws ec2 describe-images --image-ids "$newAMI"
        printf '\n%s\n\n' "  Ready for Terraforming!"
    fi
fi


###---
### fin~
###---
exit 0
