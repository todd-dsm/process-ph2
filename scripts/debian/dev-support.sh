#!/usr/bin/env bash
# PURPOSE: A QnD script: changes the default 'editor' from nano -> vim
#    TODO: 1) Make it more portable; it only works on Debian.
#          2)
set -eux

export DEBIAN_FRONTEND=noninteractive

# check the defaults
printf '%s\n' "Display the defaults before changing anything..."
update-alternatives --list editor
update-alternatives --display editor


# Set packages for removal
printf '%s\n' "Remove the unwanted packages..."
sudo apt-get -y --purge remove vim-tiny nano

# Install Vim and other dev support packages
# This will trigger an alternatives update but only to /usr/bin/vim.basic
# We want: /usr/bin/vim - priority 0
printf '%s\n' "Installing Vim and other development packages..."
sudo apt-get -y install vim git

# update the alternatives to point to Vim
printf '%s\n' "Updating system-wide alternatives..."
update-alternatives --install                                      \
    /usr/bin/editor editor /usr/bin/vim 0                          \
    --slave /usr/share/man/man1/editor.1.gz editor.1.gz            \
    /usr/share/man/man1/vim.1.gz

# Set an alternatives 'alias' that points to Vim
printf '%s\n' "Creating an alternatives alias for vim..."
sudo update-alternatives --set editor /usr/bin/vim


# check the defaults
printf '%s\n' "Display the changes..."
update-alternatives --list editor
update-alternatives --display editor

exit 0
