#!/bin/bash

# Strubloid::linux::programs

## this is to install the htop on linux
function install-htop() {
    sudo apt-get update
    sudo apt-get install -y htop
}

## this is to install the terminator on linux
function install-terminator() {
    sudo apt-get update && sudo apt-get install -y terminator
}

## this is to install the vim on linux
function install-vim() {
    sudo apt-get update && sudo apt-get install -y vim
}

## this is to install sublime text on linux
function install-sublime() {

  ## installing the sublime
  echo "installing the sublime text"
  sudo snap install sublime-text --classic
}