#!/bin/bash

# Strubloid::general::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"

# git basic commands
alias gc="git commit -m"
alias gs="git status"

# tags
alias gt-tag-c="git tag "


usage-gittag()
{
  echo "Usage: alphabet [ -a | --alpha ] [ -b | --beta ]
                        [ -c | --charlie CHARLIE ]
                        [ -d | --delta   DELTA   ] filename(s)"
  exit 2
}

gittag()
{
#  for param in "$@"; do
#    echo $param ==null
#    if [ -z "$param" ]
#    then
#      printf "[ERR]: You must pass this argument to use this function"
#    fi
#  done
printf "Welcome to GITtag\n"

# Option strings
SHORT=ad:
LONG=add,del:

# read the options
OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")

if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# set initial values
VERBOSE=false

# extract options and their arguments into variables.
while true ; do
  case "$1" in
      -add | --add )
        printf "Now you will be passing: Message, Tag name and Git Id (Optional)\n"
        printf "(Optional)-> Means that will get the current commitID\n"
        read -p "Message : " message
        read -p "Tag Name : " tag
        read -p "Git Id : " id
        if [ -z "$id" ]
        then
          git tag -am $message $tag
        else
          git tag -am $message $tag $id
        fi
      shift
      ;;
    -del | --del )
        read -p "Tagname to delete : " tag
        git tag del $tag
      shift
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# Print the variables
echo "VERBOSE = $VERBOSE"
echo "FILE = $FILE"

}

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


