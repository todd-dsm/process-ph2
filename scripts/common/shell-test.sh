#!/bin/bash
# PURPOSE: A QnD script to discover which shell is being used for execution.
set -eux

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
whatshellURL='http://www.in-ulm.de/~mascheck/various/whatshell/whatshell.sh'

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
waitForIt() {
    theDuration="$1"
    sleep "$theDuration"
}

###----------------------------------------------------------------------------
### MAIN
###----------------------------------------------------------------------------
### Test ENV VARS
###---
printf '%s\n' "TESTING \$HOME_DIR..."
ls -ld "$HOME_DIR"
printf '%s\n' "TESTING \$backupDir..."
echo "$backupDir"
waitForIt 1


### Where are we installing from?
###---
printf '%s\n' "Where are we installing from? "
pwd
waitForIt 1


###---
### Who is the excutor?
###---
printf '%s\n' "Who is the excutor? "
whoami
waitForIt 1


### Get the default shell
###---
printf '%s\n' "Print the shell in use:"
ps -p "$$"
waitForIt 1


###---
### Where does that shell point?
###---
ls -l /bin/sh
waitForIt 1


###---
### Switch /bin/sh -> bash
###---
echo 'dash dash/sh boolean false' | debconf-set-selections && \
    dpkg-reconfigure -p 'high' dash
waitForIt 1


### Where does that shell point now?
ls -l /bin/sh
waitForIt 1


###---
### Get details about the current shell
###---
### pull whatshell down
wget "$whatshellURL" >/dev/null 2>&1


### make it executable
chmod u+x whatshell.sh >/dev/null 2>&1


###---
### What Shell ran the script?
###---
printf '%s\n' "Which shell are we using now? "
./whatshell.sh


###---
### Remove the script
###---
rm -f whatshell.sh >/dev/null 2>&1


###---
### Fin~
###---
exit 0
