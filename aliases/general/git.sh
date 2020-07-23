#!/bin/bash

# Strubloid::general::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"


# git basic commands
alias gc="git commit -m"
alias gs="git status"

gitpush()
{
    if [ -z "$1" ]
    then
      printf "[ERR]: You must pass an argument to use this function"
    else
      printf "Git message: $1\n"
      git commit -m "$1" && git push origin master
    fi
}
