#!/usr/bin/env bash
# When using the amazon-ebs Packer builder the process begins with a different
# source, an existing AMI. The preseed packages need to be moved to a script so
# they are included in on the golden image.
set -x

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
qPkgs=('nfs-common' 'cryptsetup' 'bzip2' 'vim' 'acpid' 'curl' 'zlib1g-dev' 'python-pip')

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
# Install packages from preseed.cfg
# ---
apt-get install -y sudo apt-utils wget python


# ---
# Are these packages installed?
# ---
printf '%s\n'
for package in "${qPkgs[@]}"; do
    printf '%s\n\n' "Installed?  $package"
    type -P "$package"
done

# There are some problematic packages:
apt-get install -y cryptsetup bzip2 vim acpid curl zlib1g-dev python-pip

# dkms isn't necessary any more.

