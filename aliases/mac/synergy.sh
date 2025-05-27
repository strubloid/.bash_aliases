#!/bin/zsh

# Strubloid::mac::synergy

# how to delete all synergy process
alias killsynery="sudo killall -9 synergys"

# how to list synegy PID's
# alias mac-synergy-pids="ps -eo pid,ni,args | grep synergy | grep -v grep | cut -d" " -f2 | while read pid; do printf $pid" "; done"

# Increasing schedule
# alias mac-synergy-super="ps -eo pid,ni,args | grep synergy | grep -v grep | cut -d" " -f2 | while read pid; do printf $pid" "; done | xargs renice -19"
