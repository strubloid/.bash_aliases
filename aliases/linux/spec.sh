#!/bin/bash

# Strubloid::linux::spec

# git aliases
alias spec-basic-project="uvx --from git+https://github.com/github/spec-kit.git specify init basic-project"


spec-start-project() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Project Name]: " ProjectName
  else
      # mounting the spec name
      ProjectName="$1"
  fi

  # Check if project name is empty
  if [ -z "$ProjectName" ]
  then
      echo "Error: Missing project name"
      return 1
  fi
  
  uvx --from git+https://github.com/github/spec-kit.git specify init "$ProjectName"

}
