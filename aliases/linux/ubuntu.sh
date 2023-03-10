#!/bin/bash

# Strubloid::linux::ubuntu

function cleanScreenshotKeyValue() {
  gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot ''
}

function check-network() {
  # this will see the dns cache list
  sudo systemd-resolve --statistics
}

# ref: https://github.com/apache/incubator-mxnet/issues/5385
#      https://askubuntu.com/questions/893922/ubuntu-16-04-gives-x-error-of-failed-request-badvalue-integer-parameter-out-o
function remove-nvidia-back-to-intel() {
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
function install-hp-deskJet-2600() {
  ## Install of the hplib and hplib-gui
  sudo apt install hplip hplip-gui

  ## Setup for the printer
  if [ -n "$1" ]; then
    hp-setup $1
  else
    printf "Do you want to specify an IP ?\n[Y or N]: "
    read addIpQuestion
    if [ "$addIpQuestion" == "Y" ] || [ "$addIpQuestion" == "y" ]; then
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

function removeEvolutionAlarmNotify() {
  textToFind="OnlyShowIn=GNOME;Unity;XFCE;Dawati;MATE;"
  textToReplace="NotShowIn=GNOME;"

  sudo sed -i -e "s/$textToFind/$textToReplace/g" /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop

}

function enableEvolutionAlarmNotify() {
  textToFind="NotShowIn=GNOME;"
  textToReplace="OnlyShowIn=GNOME;Unity;XFCE;Dawati;MATE;"

  sudo sed -i -e "s/$textToFind/$textToReplace/g" /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop
}

function disableSnapStore() {
  snap disable snap-store
}

function disableSnapStore() {
  snap enable snap-store
}

function infoSnapStore() {
  snap info snap-store
}

function editShortcutsUbuntu() {
  nautilus ~/.local/share/applications
}

#references: https://gitlab.com/leinardi/gwe
#            https://www.youtube.com/watch?v=E7pcZrPomZE
function createOverclock() {
  a=1
}

function greenWithEnvy() {
  flatpak run com.leinardi.gwe
}


function turnOffMonitors()
{
  # you must check for the result of:
  # xrandr -q

  # Top monitor On
  xrandr --output HDMI-0 --brightness 1
  # Top monitor Off
  xrandr --output HDMI-0 --brightness 0

  # Laptop monitor On
  xrandr --output DP-0 --brightness 1
  # Laptop  monitor Off
  xrandr --output DP-0 --brightness 0

  # USB Monitor On
  xrandr --output DVI-I-1-1 --brightness 1
  # USB Monitor Off
  xrandr --output DVI-I-1-1 --brightness 0
}

function reset-a()
{
  sudo killall pulseaudio; rm -rf ~/.config/pulse/* ; rm -rf ~/.pulse*
}

function fix-missing-settings() {
    sudo apt-get update
    sudo apt-get install --reinstall gnome-control-center -y
}

function creating-www-group()
{

  sudo addgroup www-data
  sudo usermod -a -G www-data www-data
  adduser  www-data www-data && exit 0 ; exit 1
}

function add-user-to-www-data-group()
{
  sudo usermod -a -G www-data "$USER"
}

