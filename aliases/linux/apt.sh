#!/bin/bash

# Strubloid::linux::apt

# Reference: https://futurestud.io/tutorials/fix-ubuntu-debian-apt-get-keyexpired-the-following-signatures-were-invalid
apt-find-expired-key() {
  sudo apt-key list | grep -A 1 expired
}

# Reference: https://futurestud.io/tutorials/fix-ubuntu-debian-apt-get-keyexpired-the-following-signatures-were-invalid
apt-renew-key()
{
   sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$1"
}

apt-refresh-all-keys()
{
   sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
}

apt-clean-temporary ()
{
  sudo apt-get clean
}

apt-clean-unsused ()
{
  sudo apt-get autoremove
}
