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

  ## installing the key of sublime text
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null

  ## updating the apt sources list
  sudo apt update

  ## installing the sublime text
  sudo apt install -y sublime-text
}