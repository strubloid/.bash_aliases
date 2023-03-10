#!/bin/bash

# Strubloid::linux::nvm

nvm-update-npm() {
  nvm install-latest-npm
}

nvm-refresh(){
  nvm ls-remote
}

nvm-list() {
  nvm list
}

nvm-latest-node() {
  nvm install --lts
}

