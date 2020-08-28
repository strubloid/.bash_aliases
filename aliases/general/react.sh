#!/bin/bash

# Strubloid::general::react

## react js commands
react-create(){

  if [ -z "$1" ]
    then
        npx create-react-app .
    else
        npx create-react-app . $1
  fi
}