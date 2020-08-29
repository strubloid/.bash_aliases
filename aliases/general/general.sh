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
    echo "[missing]: file.extension \n"
    STOPFLAG=1;
  fi

  if [ ! -n "$2" ]; then
    echo "[missing]: needle \n"
    STOPFLAG=1;
  fi

  if [ ! -n "$3" ]; then
    echo "[missing]: haystack \n"
    STOPFLAG=1;
  fi

  ## If nothing is missing it will run
  if [ $STOPFLAG == 0 ]; then
    perl -i -pe 's/'$2'/'$3'/g' $1
  fi
}