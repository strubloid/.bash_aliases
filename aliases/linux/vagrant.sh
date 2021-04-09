#!/bin/bash

# Strubloid::linux::Vagrant

function vg-up() {
    printf "[]: Debugging vagrant up command: "
    VAGRANT_LOG=debug vagrant up
}

function vg-ssh-config() {
    printf "[]: Checking ssh configs for a loaded box "
    vagrant ssh-config
}

function vagrant-up-detailed(){
  VAGRANT_LOG=info vagrant up --provider=virtualbox
}
# 185.57.119.34
# 185.57.117.34
