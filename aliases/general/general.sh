#!/bin/bash

# Strubloid::general::general


# This will return where is the project folder
getProjectFolder()
{
  echo $BASH_ALIASES_PROJECT_FOLDER;
}

# This will change a content of a file, you have the syntax
# changeInFile [file] [search] [repplace]
# sample:
# changeInFile file.txt "regex-word-to-search" "replacement"
changeInFile()
{
  STOPFLAG=0;

  if [ ! -n "$1" ]; then
    echo "[missing]: regex to search\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$2" ]; then
    echo "[missing]: replacement\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$3" ]; then
    echo "[missing]: file to replace data\n"
    STOPFLAG=1;
  fi

  # checking if the file exist or not
  if [ ! -f "$3" ]; then
    echo "[$3]: file does not exist\n"
    STOPFLAG=1;
  fi

  ## If nothing is missing it will run
  if [ $STOPFLAG == 0 ]; then

    commandBuild="s/$1/$2/g"
    # echo $commandBuild $3

    perl -i -pe "$commandBuild" "$3"
  fi
}

checkInFile() {

  STOPFLAG=0;

  if [ ! -n "$1" ]; then
    echo "[missing]: search\n"
    STOPFLAG=1;
  fi

  if [ ! -n "$2" ]; then
    echo "[missing]: file to search\n"
    STOPFLAG=1;
  fi

    # checking if the file exist or not
  if [ ! -f "$2" ]; then
    echo "[$2]: file does not exist\n"
    STOPFLAG=1;
  fi

  ## If nothing is missing it will run
  if [ $STOPFLAG == 0 ]; then

    EXISTLINE=$(grep -F "$1" $2)
    if [[ ${EXISTLINE} ]]; then
      echo "1"
    else
      echo "0"
    fi
  else
    echo 'error'
  fi

}
