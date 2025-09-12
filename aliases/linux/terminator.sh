#!/bin/bash

# Strubloid::linux::terminator

tw(){
  terminator -l work &
}

terminator-work() {
  terminator -l work -p work &
}

t2() {
  terminator -l work-2 -p work &
}

edit-teminator()
{
  subl ~/.config/terminator/config &
}


t9() {
  terminator -l New-9 -p work &
}


mining() {
  terminator -l Mining -p work &
}

t3() {
  terminator -l Docker -p work &
}
