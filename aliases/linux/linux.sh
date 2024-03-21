#!/bin/bash

# Strubloid::linux::linux

# Debian aliases
alias update='sudo apt-get update && sudo apt-get upgrade'
alias apt-get="sudo apt-get"
alias aptitudey="sudo aptitude -y"
alias aptitude="sudo aptitude"
alias updatey="sudo apt-get --yes"

# changing the system blacklight
alias rafael-monitor-low="sudo sh -c 'echo 30 > /sys/class/backlight/nvidia_0/brightness'"
alias rafael-monitor-medium="sudo sh -c 'echo 50 > /sys/class/backlight/nvidia_0/brightness'"
alias rafael-monitor-high="sudo sh -c 'echo 80 > /sys/class/backlight/nvidia_0/brightness'"
alias fix-monitor-rafa="xrandr --output eDP1 --auto --output DP1 --auto --scale 2x2 --right-of eDP1"

# checking linux errors
alias rafael-linux-errors="journalctl -f -n 0"

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

# handy short cuts #
alias h='history'
alias j='jobs -l'
alias diff='colordiff' # install colordiff package
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log' # get GPU ram on desktop / laptop
alias update-java="sudo update-alternatives --config java"    # alias for java

## Manjaro Aliases

## Pacman
alias apt2-i='sudo pacman -S'    # install of a package
alias apt2-r='sudo pacman -Rs'   # removing a package
alias apt2-s='sudo pacman -Ss'   # search of a package
alias apt2-up='sudo pacman -Syu' # package upgrade

## remove mirrors that are failing
alias apt2-up-mirrors="sudo pacman-mirrors -g && sudo pacman -Syy && sync"

## upgrade the debtap
alias debtap-u="sudo debtap -u"

## Rafa tips
alias rafa-memory-available="cat /proc/meminfo"
alias rafa-memory-availablew="watch -n 3 cat /proc/meminfo"

alias rafa-memory-free="free -m"
alias rafa-memory-freew="watch -n 3 free -m"

alias rafa-buffers-clean="sync"
alias rafa-buffers-cleanw="watch -n 900 sync"

## how to get the current X?
alias rafa-current-x="cat /etc/X11/default-display-manager"

alias restart-x1="sudo /etc/init.d/gdm3 restart"
alias restart-x2="sudo systemctl restart gdm.service"
alias restart-x3="sudo service gdm3 restart"
alias restart-x4="dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()' && fix-monitor-rafa"
alias fix-gnome-shell="gsettings set org.gnome.desktop.interface clock-show-seconds false"

### ways to restart the X
# sudo /etc/init.d/gdm3 restart
# systemctl restart gdm.service
# sudo service gdm3 restart
# dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'

alias check-url-time="curl -s -w 'Testing Website Response Time for :%{url_effective}\n\nLookup Time:\t\t%{time_namelookup}\nConnect Time:\t\t%{time_connect}\nPre-transfer Time:\t%{time_pretransfer}\nStart-transfer Time:\t%{time_starttransfer}\n\nTotal Time:\t\t%{time_total}\n' -o /dev/null "
alias check-url-time-w1=" watch -n 1 curl -s -w 'Testing Website Response Time for :%{url_effective}\n\nLookup Time:\t\t%{time_namelookup}\nConnect Time:\t\t%{time_connect}\nPre-transfer Time:\t%{time_pretransfer}\nStart-transfer Time:\t%{time_starttransfer}\n\nTotal Time:\t\t%{time_total}\n' -o /dev/null "
alias check-url-time-w10=" watch -n 10 curl -s -w 'Testing Website Response Time for :%{url_effective}\n\nLookup Time:\t\t%{time_namelookup}\nConnect Time:\t\t%{time_connect}\nPre-transfer Time:\t%{time_pretransfer}\nStart-transfer Time:\t%{time_starttransfer}\n\nTotal Time:\t\t%{time_total}\n' -o /dev/null "
alias rafa-check-process='watch -n 1 "inxi -t cm"'

alias linux-monitor-scale-small="sudo xrandr --output eDP1 --scale 2.0x2.0"
alias linux-monitor-scale-medium="sudo xrandr --output eDP1 --scale 1.5x1.5"
alias linux-monitor-scale-big="sudo xrandr --output eDP1 --scale 1.0x1.0"

alias create12Gswap="sudo fallocate -l 12G /swapfile && sudo chmod 600 /swapfile &&  && sudo mkswap /swapfile && sudo swapon /swapfile"
alias save12Gswap="sudo echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab"
#alias fix-monitor-rafa="xrandr --output eDP1 --auto --pos 3200x0 --dpi 272 --output DP1 --auto --dpi 272 --scale 1.66x1.66 --pos 0x0 --fb 6400x1800"
# https://unix.stackexchange.com/questions/313612/scaling-problem-using-ultra-hd-resolution-between-a-laptop-and-a-monitor

function whatIsTheCurrentDriveWifi() {
    nmcli
}

## this checks what is the dns applied for each device
function dns-status() {

    ## lshw -c network
    systemd-resolve --status
    # resolvectl status
}

function dns-cache-list() {
    sudo systemd-resolve --statistics
}

function dns-cache-flush() {
    sudo systemd-resolve --flush-caches

    ## sudo systemctl stop resolvconf.service
    ## sudo systemctl start resolvconf.service
}

function dns-cache-flush-all() {

    dns-cache-flush

    sudo systemctl restart systemd-resolved

    ## those worked
    sudo systemctl restart network-manager.service
    sudo systemd-resolve --flush-caches

    ## check the file doing:
    # sudo vim /etc/dhcp/dhclient.conf
    ## uncomment lines: +
    ## #supersede domain-name "fugue.com home.vix.com";
    ## #prepend domain-name-servers 127.0.0.1;

    ## Check this file if the problem still persists
    ## systemctl stop resolvconf.service;systemctl start resolvconf.service

}

function find-new-file-current-folder()
{
    find . -daystart -ctime 0 -print
}

function machine-name()
{
  hostnamectl
}

function machine-hostname()
{
  hostname
}

digForMyIP()
{
  dig +short myip.opendns.com resolver1.opendns.com
}

whatIsMyIP()
{
  digForMyIP
}

check-disks-avability()
{
  lsblk
}

create-4G-Swap()
{
  sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
}

check-HDs()
{
  df -t ext4
}

searchForBiggerThan50MBFiles()
{
  sudo find / -type f -size +50M -exec ls -lh {} \;
}

searchBiggerThan()
{
  if [ -z "$1" ]
  then
      read -p "What is the minimum size of the file : " minimumSize
  else
    minimumSize=$1
  fi
  sudo find / -type f -size +"$minimumSize"M -exec ls -lh {} \;
}

changeMyEditor()
{
  sudo update-alternatives --config editor
}

bettertree()
{
  tree --du -h "$1"
}

bt()
{
  tree --du -h "$1"
}

wt()
{
  watch -n 1 tree --du -h "$1"
}

findIP()
{
  wget --server-response "$1" 2>&1 | head  -n2 | awk '{print $4}'
}

mkdir-today()
{
  mkdir -p $(date +"%Y-%m-%d")
}

show-all-linux-headers()
{
  dpkg --list | egrep -i --color 'linux-image|linux-headers'
}

show-installed-linux-headers()
{
  dpkg --list | grep -i -E --color 'linux-image|linux-kernel' | grep '^ii'
}

monitor-off()
{
  xset dpms force off
}

monitor-on()
{
  xset dpms force on
}

monitors-sleep()
{
  xrandr --output HDMI-0 --brightness 0 && xrandr --output DP-0 --brightness 0
}

monitors-awake()
{
  xrandr --output HDMI-0 --brightness 1
  xrandr --output DP-0 --brightness 1
}

# This will be resizing a file to a specific size, removing
# things from the past of the file til get the actual required size, like:
#  sudo truncate /var/log/auth.log  --size 100MB
#  this will go to the auth.log and make it maximum 100MB
# our program would be:
#  resize-file '/var/log/auth.log' '100MB'
#
resize-file(){

  if [ -z "$1" ]
  then
      read -p "What is the file to resize : " filePath
  else
    filePath=$1
  fi

  if [ -z "$2" ]
  then
      read -p "What is the maximum size of the file? " fileSize
  else
    fileSize=$2
  fi

  sudo truncate $filePath  --size $fileSize
}

# this will search in th ecurrent folder and
# will show what are the deleted filed by extension
# that will be done if a person run bazinga-remove-extension
# reference: https://askubuntu.com/questions/377438/how-can-i-recursively-delete-all-files-of-a-specific-extension-in-the-current-di
bazinga-search-extension()
{
  if [ -z "$1" ]
  then
      read -p "What is the file to resize : " fileExtension
  else
    fileExtension=$1
  fi

  ## this will search by the extension and print afterwards
  find . -name "*.$fileExtension" -type f | xargs echo rm -rf

}

# This will remove files by the extension passed
bazinga-remove-extension()
{
  if [ -z "$1" ]
  then
      read -p "What is the file to resize : " fileExtension
  else
    fileExtension=$1
  fi

  ## this will search by the extension and print afterwards
  find . -name "*.$fileExtension" -type f | xargs rm -rf

}




compress-file-ffmpeg()
{
    # Loading the file to compress
    if [ -z "$1" ]
    then
        read -p "[file]: " FILE_TO_COMPRESS_FFMPEG
    else
        FILE_TO_COMPRESS_FFMPEG="$1"
    fi

    echo "Generating the file: $compressed" "_" "$1"
}

