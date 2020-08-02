#!/bin/bash

# Strubloid::mac::terminal

# alias ls='ls -hp'
alias ls='ls -FlGAH'
alias ll='ls -FlGh'

# Extra ls configurations for mac
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

cd() { builtin cd "$@"; ls; }

# get processes eating memory
alias psmem='ps aux | sort -nr -k 4'

# get top 10 process eating memory
alias psmem10='ps aux | sort -nr -k 4 | head -10'

# f: Opens current directory in MacOS Finder
alias f='open -a Finder ./'

# Show_options: display bash options settings
alias show_options='shopt'

# fix_stty:     Restore terminal settings when screwed up
alias fix_stty='stty sane'

# cic: Make tab-completion case-insensitive
alias cic='set completion-ignore-case On'

# DT: Pipe content to file on MacOS Desktop
alias DT='tee ~/Desktop/terminalOut.txt'

# check what WindowServer is doing now
alias windowServerCheck='sudo spindump -reveal $(pgrep WindowServer)'

# trash: Moves a file to the MacOS trash
trash () { command mv "$@" ~/.Trash ; }

# ql: Opens any file in MacOS Quicklook Preview
ql () { qlmanage -p "$*" >& /dev/null; }
