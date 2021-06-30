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