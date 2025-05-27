#!/bin/bash

# Strubloid::linux::synergy

# how to delete all synergy process
alias killsynery="sudo killall -9 synergys"

# how to list synegy PID's
# alias synergy-pids="ps -eo pid,ni,cmd | grep synergy | grep -v grep | cut -d" " -f2 | while read pid; do printf $pid" "; done"

# Increasing schedule
# alias synergy-super="ps -eo pid,ni,cmd | grep synergy | grep -v grep | cut -d" " -f2 | while read pid; do printf $pid" "; done | xargs renice -19"
