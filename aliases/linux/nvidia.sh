#!/bin/bash

# Strubloid::linux::nvidianginx

function upgrade-configuration()
{
  sudo nvidia-smi -i 0 -pl 100
  sudo nvidia-xconfig
}