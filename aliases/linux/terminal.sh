#!/bin/bash

# Strubloid::linux::terminal

# Basic commands

# Preferred 'ls' implementation
alias ls='ls -FlAhp --color=auto'

ls-watch(){
watch -n 1 'stat -c "- %s %n" *'
}



#   lr:  Full Recursive Directory Listing
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

# cpu info
alias cpuinfo='lscpu'

# get processes eating memory
alias psmem='ps auxf | sort -nr -k 4'

# get top 10 process eating memory
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

## pass options to free ##
alias meminfo='free -m -l -t'

# Mate #
alias restart-mate="gsettings reset-recursively org.mate.panel";

# Memory management #
alias swap-cache-off="sudo swapoff -a";
alias swap-cache-on="sudo swapon -a";
alias swap-cache-restart="swapoff -a && swapon -a";

# How to clean memory in linux systems
alias linux-memory-clean-1="sudo echo 1 > /proc/sys/vm/drop_caches"        # cleaninig the page cache
alias linux-memory-clean-2="sudo echo 2 > /proc/sys/vm/drop_caches"        # cleaning Dentries and Inodes
alias linux-memory-clean-3="sudo echo 3 > /proc/sys/vm/drop_caches"        # cleaninig page cache, dentries and Inodes

# Trackpad #
alias touchpad-off="synclient TouchpadOff=1"                               # Trackpad off on UBUNTU
alias touchpad-on="synclient TouchpadOff=0"                                # Trackpad on on UBUNTU

## how to see who is loading in the boot
alias rafa-boot-time="systemd-analyze blame"

## see all linux versions of it
alias linuxversion="cat /etc/*-release"
