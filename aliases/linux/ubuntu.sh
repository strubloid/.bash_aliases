#!/bin/bash

# Strubloid::linux::ubuntu

# Collect a concise but rich error report from this boot (and a few previous boots).
# Usage:
#   computer_errors                 # default (last 300 lines per section)
#   computer_errors -n 600          # increase lines per section
#   computer_errors -o /path/file   # choose output file
computer_errors() {
  local LINES=300 OUT=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -n) LINES="${2:-300}"; shift 2;;
      -o) OUT="$2"; shift 2;;
      *)  echo "Usage: computer_errors [-n LINES] [-o OUTPUT_FILE]"; return 2;;
    esac
  done

  # Decide privilege runner (root or sudo if available)
  local SUDO=""
  if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    fi
  fi

  # Output file
  local TS; TS="$(date +%Y%m%d-%H%M%S 2>/dev/null || printf 'now')"
  [ -n "$OUT" ] || OUT="/tmp/sysreport-$TS.txt"

  # Helper to section + safe run (never abort on failure)
  _sec() { printf "\n===== %s =====\n" "$1"; }
  _run() { sh -c "$*" 2>&1 || true; }

  {
    printf "HOST: %s  |  TIME: %s  |  KERNEL: %s  |  BOOTID: %s\n" \
      "$(hostname 2>/dev/null || echo '?')" \
      "$(date -Is 2>/dev/null || date 2>/dev/null || echo '?')" \
      "$(uname -r 2>/dev/null || echo '?')" \
      "$($SUDO cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo '?')"

    _sec "SYSTEMD FAILED UNITS (this boot)"
    _run "$SUDO systemctl --failed --no-pager"

    _sec "RECENT ERRORS from journalctl (this boot, priorities err..alert)"
    _run "$SUDO journalctl -b -p err..alert --no-pager | tail -n $LINES"

    _sec "KERNEL ERR/WARN (dmesg)"
    # If privileged, include timestamps & levels; otherwise best-effort.
    if [ "$EUID" -eq 0 ] || [ -n "$SUDO" ]; then
      _run "$SUDO dmesg -T --level=emerg,alert,crit,err,warn | tail -n $LINES"
    else
      _run "dmesg  | tail -n $LINES"
    fi

    _sec "DISPLAY/GDM/GNOME related (last $LINES lines)"
    _run "$SUDO journalctl -b -u gdm3 --no-pager | tail -n $LINES"
    _run "$SUDO journalctl -b --no-pager | grep -Ei 'gnome|gdm|gkr-pam|keyring' | tail -n $LINES"

    _sec "NVIDIA / DRM messages (last $LINES lines)"
    _run "$SUDO journalctl -b -k --no-pager | grep -Ei 'nvidia|drm|modeset' | tail -n $LINES"

    _sec "POLKIT / SUDO messages (last $LINES lines)"
    _run "$SUDO journalctl -b --no-pager | grep -Ei 'polkit|policykit|sudo' | tail -n $LINES"

    _sec "CHECK: Dynamic loader presence"
    for p in /lib64/ld-linux-x86-64.so.2 /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2; do
      if [ -e "$p" ]; then echo "$p : PRESENT"; else echo "$p : MISSING"; fi
    done
    [ -L /lib64 ] && echo "/lib64 is a symlink" || echo "/lib64 is not a symlink"

    _sec "SCAN: 'Exec format error' occurrences (this boot)"
    _run "$SUDO journalctl -xb --no-pager | grep -i 'exec format' | tail -n $LINES"

    _sec "PACKAGE: file (sanity & versions if available)"
    _run "$SUDO dpkg -s file | sed -n '1,40p'"
    _run "$SUDO dpkg -V file"
    _run "apt-cache policy file 2>/dev/null | sed -n '1,40p'"

    _sec "RECENT ERRORS from previous boots (up to 3 prior boots)"
    for i in 1 2 3; do
      echo "-- previous boot -$i --"
      _run "$SUDO journalctl -b -$i -p err..alert --no-pager | tail -n $LINES"
    done

    _sec "FALLBACK: syslog/kern.log tail (if journal unavailable)"
    _run "tail -n $LINES /var/log/syslog"
    _run "tail -n $LINES /var/log/kern.log"
  } | tee "$OUT" >/dev/null

  echo "Report saved to: $OUT"
}


function cleanScreenshotKeyValue() {
  gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot ''
}

function check-network() {
  # this will see the dns cache list
  sudo systemd-resolve --statistics
}

function whatIsMyIpOutside(){
  curl ifconfig.me
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

function system-check-errors()
{
  sudo dmesg -w
}

function watch-system()
{
  sudo dmesg -w
}

## make sure to check how we can create a new shortcut for
## be able to find using the window key search.
## TODO: Double check this, feels needs add more functionality
function creatingShortcutUbuntu(){

    # getting name
    read -p "What is the name of it? " name

    # getting the path to binary
    read -p "What is binary path? " path

## /home/zero/programs/Linux_Unreal_Engine_5.3.2/Engine/Binaries/Linux

    # getting the path to image
    read -p "What is the path to the SVG file?" svg

## /home/zero/programs/Linux_Unreal_Engine_5.3.2/unreal-engine.svg
# Multiline variable sample
SHORTCUT=$(cat << END

[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=Develop with pleasure!
Exec=$path
Icon=$svg
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-idea-ce
Categories=Development;IDE;Java;


END
)
  # configure the variables before run it
  echo $SHORTCUT > ~/.local/share/applications/$name.desktop

}



# How to open touch portal
function touchportal-start()
{
  cd "/media/games/dev/TouchPortal"
  chmod +x TouchPortal.AppImage
  ./TouchPortal.AppImage
}

