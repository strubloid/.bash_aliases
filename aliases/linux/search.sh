#!/bin/bash

# Strubloid::linux::search

searchlist()
{
  ## words that we will be searching for
  search_list=()

  ## First argument is the list of words
  if [ -z "$1" ]
  then
    read -p "[List of words]: " search_string_list
  else
    search_string_list="$1"
  fi

  ## transforming into an array
  read -a search_list <<< "$search_string_list"

  ## Second argument is the folder
  if [ -z "$2" ]
  then
      ## Check if the user wants to use the local folder
      read -p "Use local folder? [y/n] : " useLocalFolder

      if [[ "$useLocalFolder" =~ [yY](es)?$ ]]; then
        folderToCheck=$(pwd)
      else
        read -p "Folder path : " folderToCheck
      fi
  fi

  ## entering the folder
  cd "$folderToCheck"

  # Iterate through the search_list
  for search_text in "${search_list[@]}"; do

    printf "$search_text => "

    foundOnThoseFiles=$(grep -rl --exclude-dir="vendor" "$search_text" . | grep ".php")
    if [ -n "$foundOnThoseFiles" ]; then

        printf "yes \n"
        printf " $foundOnThoseFiles \n"

        foundElements=$foundOnThoseFiles
    else
        printf "No \n"
        notFoundElements=$foundOnThoseFiles
    fi

  done

}