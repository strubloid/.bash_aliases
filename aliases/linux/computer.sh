#!/bin/bash

# Strubloid::linux::configs

computer-show()
{
    inxi -Fxz
}

computer-show-video()
{
  lspci -nnk | grep -EA3 "3D|VGA"
}

computer-show-audio()
{
  sudo lspci -vv | grep -i audio
}

computer-show-audio-2()
{
  sudo dmesg | grep -i audio
}