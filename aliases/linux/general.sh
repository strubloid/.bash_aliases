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