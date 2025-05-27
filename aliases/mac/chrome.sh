#!/bin/zsh

# Strubloid::linux::terminator

# Mac   : located in ~/Library/Application Support/Google/Chrome
# Linux : located in ~/.config/google-chrome.
# Win7  : located in %USERPROFILE%\AppData\Local\Google\Chrome\User Data
edit-chrome-profile()
{
  subl  ~/Library/Application Support/Google/Chrome &
}

# This will be opening the chrome in the correct profile
open-chrome-profile()
{
  open -a "Google Chrome" --args --profile-directory=Default
}