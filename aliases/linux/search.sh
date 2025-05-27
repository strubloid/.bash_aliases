#!/bin/bash

# Strubloid::linux::search

## This will be responsible to log the found elements
logFoundElement()
{
  ## loading the filepath to paste the content
  foundElementsFilepath="$BASH_ALIASES_PROJECT_FOLDER/search/found_elements.csv"

  ## loading the first argument
  elementToSet=$1

  ## adding into the file
  echo "$elementToSet" >> "$foundElementsFilepath"

}

## This will be responsible to log the not found elements
logNotFoundElement()
{
  ## loading the filepath to paste the content
  notFoundElementsFilepath="$BASH_ALIASES_PROJECT_FOLDER/search/not_found_elements.csv"

  ## loading the first argument
  elementToSet=$1

  ## adding into the file
  echo "$elementToSet" >> "$notFoundElementsFilepath"

}

## This is to debug the things into an array.
printArray()
{
  # Use the correct syntax to pass the array
  arrayToPrint=("$@")
  echo "${arrayToPrint[@]}"
}


searchlist()
{

  # Array of directories to exclude
  exclude_dirs=("vendor" "config" "database" "docker" "idea" "resources")
  exclude_dirs_string=$(printf ",%s" "${exclude_dirs[@]}")
  exclude_dirs_string=${exclude_dirs_string:1} # Remove the leading comma
  header="scan station field parameter, file, status"

  # Declare arrays
  foundElements=()
  notFoundElements=()
  copiedNotFoundElements=()
  declare -a search_list

  ## creating the csv part of it
  foundElementsFilepath="$BASH_ALIASES_PROJECT_FOLDER/search/found_elements.csv"
  notFoundElementsFilepath="$BASH_ALIASES_PROJECT_FOLDER/search/not_found_elements.csv"

  # Loading the search words
  readarray -t search_list < "$BASH_ALIASES_PROJECT_FOLDER/search/search_words.txt"
  if [ -z "$search_list" ]
  then
    ## getting the list of the words
    read -p "[List of words]: " search_string_list

    ## transforming into an array
    read -a search_list <<< "$search_string_list"
  fi
  searchListCount=${#search_list[@]}

  ## set of the header on both files to export
  echo "$header" > "$foundElementsFilepath"
  echo "$header" > "$notFoundElementsFilepath"
  echo "=================== [SEARCH LIST] =================== "
  echo "[VERSION] 1.0"
  echo "[TOTAL TO PROCESS]: $searchListCount"
  echo "[FILES PATH]"
  echo "=> [FOUND]: $foundElementsFilepath"
  echo "=> [NOT FOUND]: $notFoundElementsFilepath"
  echo ""

  ## First argument is the folder
  if [ -z "$1" ]; then

    read -p "(?) Use local folder? [y/n] : " useLocalFolder

    if [[ "$useLocalFolder" =~ [yY](es)?$ ]]; then
      folderToCheck=$(pwd)
    else
      read -p "(?) Folder path : " folderToCheck
    fi

  else

    ## Special case for the $1 is equal to . (current folder)
    if [[ "$1" == *.* ]]; then
      folderToCheck=$(pwd)
    else
      folderToCheck="$1"
    fi

  fi

  ## Making sure that the folder is a valid one
  echo "=================== [PROCESS LIST] =================== "
  while [ ! -d "$folderToCheck" ]; do
      echo "[$folderToCheck]: does not exist"
      read -p "What is the folder to check? " folderToCheck
  done
  echo "[FOLDER]: $folderToCheck"

  ## second parameter: first extension
  if [ -z "$2" ]
  then
    read -p "What is the extension to check? " extensionToCheck
  else
    extensionToCheck="$2"
  fi

  echo "[EXTENSION]: $extensionToCheck"

  ## third parameter: second extension
  if [ -z "$3" ];then

    read -p "Want to use another extension ? [y/N] : " wantAnotherExtension

    if [[ "$wantAnotherExtension" =~ [yY](es)?$ ]]; then
      read -p "What is the extension to check? " extensionToCheck2
    else
      extensionToCheck2=''
    fi

  else
    extensionToCheck2="$3"
  fi
  echo "[EXTENSION]: $extensionToCheck2"


  ## entering the folder if exist
  cd "$folderToCheck" || exit

  echo "[PROCESS]: Found Elements"

  # Iterate through the search_list
  for search_text in "${search_list[@]}"; do

    foundOnThoseFiles=$(grep -rl --exclude-dir={"$exclude_dirs_string"} "$search_text" . | grep ".$extensionToCheck" | grep -vE "($(IFS="|"; echo "${exclude_dirs[*]}"))")

    ## check if the foundOnThoseFiles is valid
    if [ -z "$foundOnThoseFiles" ]; then

      ## Not found case
      notFoundElements+=("$search_text, NO FILES, MISS")

      ## we are copying here so we can search it again if required extension to check 2
      copiedNotFoundElements+=("$search_text")

      ## this is to go to the next for element
      continue
    fi

    ## if was found the element, we can be sure about from this point we have something found

    ## get the foundOnThoseFiles and transform into an array
    mapfile -t foundOnThoseFilesArray <<< "$foundOnThoseFiles"

    # Check if foundOnThoseFilesArray has more than one element
    if [ "${#foundOnThoseFilesArray[@]}" -gt 1 ]; then

        # Loop through the array elements
        for found in "${foundOnThoseFilesArray[@]}"; do

          elementToSet="$search_text, $found, OK"
          foundElements+=("$elementToSet")

          ## log in found elements file
          logFoundElement "$elementToSet"

        done
    fi

  done

  ## second extension to check
  if [ -n "$extensionToCheck2" ]; then

    ## clean the notFoundElements
    notFoundElements=()

    ## now we are going to loop though the not found elements to check on $extensionToCheck2
    for search_text in "${copiedNotFoundElements[@]}"; do

      foundOnThoseFiles=$(grep -rl --exclude-dir={"$exclude_dirs_string"} "$search_text" . | grep ".$extensionToCheck2" | grep -vE "($(IFS="|"; echo "${exclude_dirs[*]}"))")

      ## check if the foundOnThoseFiles is valid
      if [ -z "$foundOnThoseFiles" ]; then

        ## Not found case
        notFoundElements+=("$search_text, NO FILES, MISS")

        ## this is to go to the next for element
        continue
      fi

      ## if was found the element, we can be sure about from this point we have something found

      ## get the foundOnThoseFiles and transform into an array
      mapfile -t foundOnThoseFilesArray <<< "$foundOnThoseFiles"

      # Check if foundOnThoseFilesArray has more than one element
      if [ "${#foundOnThoseFilesArray[@]}" -gt 1 ]; then

          # Loop through the array elements
          for found in "${foundOnThoseFilesArray[@]}"; do

            elementToSet="$search_text, $found, OK"
            foundElements+=("$elementToSet")

            ## log in found elements file
            logFoundElement "$elementToSet"

          done
      else

        elementToSet="$search_text, ${foundOnThoseFilesArray[0]}, OK"
        foundElements+=("$elementToSet")

        ## log in found elements file
        logFoundElement "$elementToSet"

      fi

    done

  fi

  echo "[Process]: Not Found Elements"
  for notFoundElement in "${notFoundElements[@]}"; do
    logNotFoundElement "$notFoundElement"
  done

}