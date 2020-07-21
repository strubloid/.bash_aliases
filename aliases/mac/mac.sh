#!/bin/bash

# Strubloid::mac::mac

# turn on or off: show hidden files
alias finderShowHiddenFiles='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHiddenFiles='defaults write com.apple.finder ShowAllFiles FALSE'

# Recursively delete .DS_Store files
alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
