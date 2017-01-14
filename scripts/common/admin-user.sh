#!/usr/bin/env bash
set -eux

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
adminHome='/home/admin'
backupDir="$adminHome/backup"

## Setup ~/.bashrc
printf '\n\n%s\n' "Setting the ~/.ssh/config file..."
cat <<EOF > "$adminHome/.ssh/config"
Host github.com
  StrictHostKeyChecking no
EOF

## Setup ~/.bashrc
printf '\n\n%s\n' "Setting the ~/.bashrc file..."
cp -pv "$adminHome/.bashrc" "$backupDir/bashrc.orig"
cat <<EOF > "$adminHome/.bashrc"
# myBashrcFile
case \$- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "\$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "\${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=\$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "\$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "\$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "\$color_prompt" = yes ]; then
    PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ '
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "\$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\${debian_chroot:+(\$debian_chroot)}\u@\h: \w\a\]\$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
###----------------------- USER ADDITIONS -------------------------------------
# some more ls aliases
alias ll='ls -l   --color=always'
alias la='ls -lAh --color=always'
alias ld='ls -ld  --color=always'
alias lh='ls -lh  --color=always'
alias lt='ls -l   --full-time --color=always'
alias cp='cp -pv'

export EDITOR='/usr/bin/vim'
alias vi="\$EDITOR"

###----------------------------------------------------------------------------
### Find Stuff on the filesystem (fs). These are starter functions. To tailor
### them to more-fit your workstyle type 'man find' (in the shell) and modify
### them until you are happy.
###----------------------------------------------------------------------------
# Find files somewhere on the system; to use:
#   1) call the alias, 'findsys'
#   2) pass a directory where the search should begin, and
#   3) pass a file name, either exact or fuzzy: e.g.:
# \$ findsys /var/ '*.log'
function findSystemStuff()   {
    findDir="\$1"
    findFSO="\$2"
    sudo find "\$findDir" -name 'proc' -prune , -name 'dev' -prune , -name 'sys' -prune , -name 'run' -prune , -name "\$findFSO"
}

alias findsys=findSystemStuff
###----------------------------------------------------------------------------
# Find fs objects (directories, files) in your home directory; To use:
#   1) call the alias, 'findmy'
#   2) pass a 'type' of fs object, either 'f' (file) or 'd' (directory)
#   3) pass the object name, either exact or fuzzy: e.g.:
# \$ findmy f '.vimr*'
function findMyStuff()   {
    findType="\$1"
    findFSO="\$2"
    find "\$HOME" -type "\$findType" -name "\$findFSO"
}

alias findmy=findMyStuff
###----------------------------------------------------------------------------
export GIT_CURL_VERBOSE=1
export GIT_TRACE=1
EOF

chown admin:admin "$adminHome/.bashrc"

###---
### Copy keys for github
###---
printf '\n\n%s\n' "Prepping ssh stuff..."
ssh-keyscan github.com   >> "$adminHome/.ssh/known_hosts"
chown -R admin:admin    "$adminHome/.ssh"
find "$adminHome/.ssh" -type f -name 'id_rsa*' -exec chmod 600 {} \;
