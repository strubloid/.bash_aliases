#!/bin/bash

# Strubloid::linux::general

function  l-show-ram-speed() {
  printf "Memory Ram definitions\n"
  sudo lshw -c memory
}

function l-show-ram() {
  printf "Current Memory Ram Status\n"
  free –m
}

