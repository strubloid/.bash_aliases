#!/bin/bash

# Strubloid::linux::time

# This will list the time configurations on your machine
get-time-configurations()
{
  timedatectl
}

check-timezones()
{
  timedatectl list-timezones
}

check-specific-timezones()
{

    if [ -z "$1" ]; then
        printf "Type location to search: "
        read commandName
        timezone="$commandName"
    else
      timezone="$1"
    fi

    timedatectl list-timezones | grep $timezone
}

set-timezone()
{
    if [ -z "$1" ]; then
        printf "Type location to search: "
        read commandName
        timezone="$commandName"
    else
      timezone="$1"
    fi

    timedatectl set-timezone $timezone
}

