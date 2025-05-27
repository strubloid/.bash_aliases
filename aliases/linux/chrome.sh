#!/bin/bash

# Strubloid::linux::terminator

# profiles are stored at:
# Linux :  ~/.config/google-chrome/[profile_name]
# Mac :  ~/Library/Application Support/Google/Chrome/[profile_name]
# Win :  %USERPROFILE%\AppData\Local\Google\Chrome/[profile_name]

# This will open a sublime editor on the
# google chrome profile page on linux
google-chrome-edit-subl()
{
  subl ~/.config/google-chrome &
}

## This will be grepping all profiles that you added profile_[profile_name]
show-google-chrome-profiles()
{
  ls ~/.config/google-chrome | grep profile
}

# This will be opening the chrome in the correct profile
open-chrome-profile()
{
  if [ -z "$1" ]
  then
    echo "[Missing Argument]: Component Name ";
    read -p "What is the minimum size of the file : " chromeProfile
  else
    chromeProfile="$1"
  fi

  printf "Opening profile: $chromeProfile V2\n"
  google-chrome --new-window --profile-directory="$chromeProfile" &

}

# Work profile
open-chrome-work()
{
    open-chrome-profile "profile_work"
}

# Bombcrypto 1
open-chrome-bombcrypto()
{
    open-chrome-profile "profile_rafael"
}

# Bombcrypto 2
open-chrome-bombcrypto2()
{
    open-chrome-profile "profile_crypto2/"
}

# Rafael
open-chrome-rafael()
{
    open-chrome-profile "profile_rafael"
}

# Strubloid
open-chrome-strubloid()
{
    open-chrome-profile "profile_strubloid"
}

# Tests
open-chrome-test()
{
    open-chrome-profile "profile_test"
}
