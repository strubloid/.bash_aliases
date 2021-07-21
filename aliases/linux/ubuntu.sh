#!/bin/bash

# Strubloid::linux::ubuntu

function cleanScreenshotKeyValue()
{
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot ''
}

function check-network()
{
    # this will see the dns cache list
    sudo systemd-resolve --statistics
}

# ref: https://github.com/apache/incubator-mxnet/issues/5385
#      https://askubuntu.com/questions/893922/ubuntu-16-04-gives-x-error-of-failed-request-badvalue-integer-parameter-out-o
function remove-nvidia-back-to-intel()
{
  sudo apt-get purge nvidia*
  sudo apt-get install --reinstall xserver-xorg-video-intel libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-core
  sudo dpkg-reconfigure xserver-xorg

  # crtl + alt + f1
  # sudo service lightdm stop
  # sudo init 3

}

function check-video() {
  lspci -k | grep -EA3 'VGA|3D|Display'
}

function fix-video() {
  LIBGL_ALWAYS_SOFTWARE=1 obs
}

function fix-network() {

    ## command to clean the dns cache
     sudo systemd-resolve --flush-caches
    # lshw -C network
    # sudo modprobe -r ath10k_pci && sudo modprobe ath10k_pci
    ## check file  ~/bin/resetWireless
}

## Reference: https://www.cyberciti.biz/faq/how-to-install-networked-hp-printer-and-scanner-on-ubuntu-linux/
function install-hp-deskJet-2600()
{
    ## Install of the hplib and hplib-gui
    sudo apt install hplip hplip-gui

    ## Setup for the printer
    if [ -n "$1" ]; then
        hp-setup $1
    else
        printf "Do you want to specify an IP ?\n[Y or N]: "
        read addIpQuestion
        if [ "$addIpQuestion" == "Y" ] || [ "$addIpQuestion" == "y" ]
        then
            printf "IP: "
            read ipPrinter
            hp-setup "$ipPrinter"
        else
            printf "Using default IP: 192.168.0.115"
            hp-setup 192.168.0.115
        fi
    fi

}

alias gksu='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY'
alias gksudo='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY'