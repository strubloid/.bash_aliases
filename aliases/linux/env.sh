#!/bin/bash

# Strubloid::general::env

loadEnvData()
{
  envData=""

  ## checking the env file path
  if [[ ! -z "$1" ]]; then
    ENV_FILE="$1"
  else
    read -p "Where is localized the .env file? " ENV_FILE
  fi

  ## checking the data to load from the env file
  if [[ ! -z "$2" ]]; then
    envVariableName="$2"
  else
    read -p "It is missing the variable name, can you please type it? " envVariableName
  fi

  ## checking if exist the env file, if does it will try to get the data from it
  if [ -f "$ENV_FILE" ]
  then

    ## getting the env file data
    envData=$(grep -v "^#" "$ENV_FILE" |  tr -d ' ' | grep . | grep -E "$envVariableName=" | cut -d'=' -f 2-)
  fi

  echo "$envData"

}