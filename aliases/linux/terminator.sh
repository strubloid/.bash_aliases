#!/bin/bash

# Strubloid::linux::terminator

terminator-blocworx() {
  terminator -l Blocworx -p Blocworx &
}

t2() {
  terminator -l Blocworx-2 -p Blocworx &
}

edit-teminator()
{
  subl ~/.config/terminator/config &
}


t9() {
  terminator -l New-9 -p Blocworx &
}


mining() {
  terminator -l Mining -p Blocworx &
}

t3() {
  terminator -l Docker -p Blocworx &
}
