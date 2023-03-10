#!/bin/bash

# Strubloid::linux::general

function  l-show-ram-speed() {
  printf "Memory Ram definitions\n"
  sudo lshw -c memory
}

function l-show-ram() {
  printf "Current Memory Ram Status\n"
  sudo /bin/su -c "free –m"
}

function firewall-log-off(){
  sudo ufw logging off
}

function firewall-log-on ()
{
  sudo ufw logging low
}

function revert-reduce-overheating ()
{
  sudo apt-get remove tlp
}

function reduce-overheating ()
{
  sudo add-apt-repository ppa:linrunner/tlp
  sudo apt-get update
  sudo apt-get install tlp tlp-rdw
  sudo tlp start
}

# reference: https://vitux.com/improving-battery-life-in-ubuntu-with-tlp/
# view detailed system information and also the status of the TLP utility
function tlp-status ()
{
  sudo tlp-stat -s
}

# configuration that is pretty much best suited for your operating system and hardware
function tlp-configs ()
{
  sudo tlp-stat -c
}

# print the detailed battery report through TLP
function tlp-battery ()
{
  sudo tlp-stat -b
}

#Timeshift is a useful backup utility that creates incremental snapshots of the file system at regular intervals.
# These snapshots can be used to restore your system to an earlier working state in case of disaster
function install-timeshift()
{
  # reference : https://www.tecmint.com/things-to-do-after-installing-ubuntu-20-04/
  sudo add-apt-repository -y ppa:teejee2008/ppa
  sudo apt-get update
  sudo apt-get install timeshift
}


