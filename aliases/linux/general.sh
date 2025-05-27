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

# This will return where is the project folder
getProjectFolder()
{
  echo $BASH_ALIASES_PROJECT_FOLDER;
}

# This will change a content of a file, you have the syntax
# changeInFile [file] [search] [repplace]
# sample:
# changeInFile file.txt "regex-word-to-search" "replacement"
changeInFile()
{
  STOPFLAG=0;

  if [ ! -n "$1" ]; then
    echo "[missing]: regex to search\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$2" ]; then
    echo "[missing]: replacement\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$3" ]; then
    echo "[missing]: file to replace data\n"
    STOPFLAG=1;
  fi

  # checking if the file exist or not
  if [ ! -f "$3" ]; then
    echo "[$3]: file does not exist\n"
    STOPFLAG=1;
  fi

  ## If nothing is missing it will run
  if [ $STOPFLAG == 0 ]; then

    commandBuild="s/$1/$2/g"
    # echo $commandBuild $3

    perl -i -pe "$commandBuild" "$3"
  fi
}

checkInFile() {

  STOPFLAG=0;

  if [ ! -n "$1" ]; then
    echo "[missing]: search\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$2" ]; then
    echo "[missing]: file to search\n"
    STOPFLAG=1;
  fi

    # checking if the file exist or not
  if [ ! -f "$2" ]; then
    echo "[$2]: file does not exist\n"
    STOPFLAG=1;
  fi

  ## If nothing is missing it will run
  if [ $STOPFLAG == 0 ]; then

    EXISTLINE=$(grep -F "$1" $2)
    if [[ ${EXISTLINE} ]]; then
      echo "1"
    else
      echo "0"
    fi
  else
    echo 'error'
  fi

}