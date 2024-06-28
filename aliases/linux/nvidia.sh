#!/bin/bash

# Strubloid::linux::nvidianginx

function upgrade-configuration()
{
  sudo nvidia-smi -i 0 -pl 100
  sudo nvidia-xconfig
}


# This will enable the first core of the gpu
# to use one of the following:
# GPUPowerMizerMode:
# 0: Auto (default, adaptive mode)
# 1: Prefer Maximum Performance
# 2: Prefer Consistent Performance (deprecated in some drivers)
function nvidia-max-performance()
{
  sudo nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1'
}

# This will enable the first core of the gpu
# to use one of the following:
# GPUPowerMizerMode:
# 0: Auto (default, adaptive mode)
# 1: Prefer Maximum Performance
# 2: Prefer Consistent Performance (deprecated in some drivers)
function nvidia-auto-performance()
{
  sudo nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=0'
}