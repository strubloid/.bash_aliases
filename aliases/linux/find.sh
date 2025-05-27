#!/bin/bash

# Strubloid::linux::find

# This is a good alias to fins something
# by only sahing the extension in the current folder
findByExtension()
{
  if [ -z "$1" ]
  then
      read -p "type the extension that you want to search: " extension
  else
    extension=$1
  fi

  find . -name $extension
}

# This is a way to search for files that are from an extension
# and later on grep the results, so if we have tons of files
# you always can get the specific line to see the result though
# multiple files from the current folder.
grepInExtension()
{

  if [ -z "$1" ]
  then
      read -p "type the extension that you want to search: " extension
  else
    extension=$1
  fi

  if [ -z "$2" ]
  then
      read -p "Please type whatever you want to grep: " greped
  else
    greped=$2
  fi

  find . -name "$extension" | xargs cat |  grep "$greped"

}
