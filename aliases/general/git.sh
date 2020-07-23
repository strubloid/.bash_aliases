#!/bin/bash

# Strubloid::general::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"


# git basic commands
alias gc="git commit -m"
alias gs="git status"
alias gpush="git commit -m $1 && git push origin master"
