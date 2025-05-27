#!/bin/zsh

# Strubloid::mac::terminal

alias ls='ls -FlGAH'
alias ll='ls -FlGh'

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

ql () { qlmanage -p "$*" >& /dev/null; }

# ql: Opens any file in MacOS Quicklook Preview
alias bashupdate="source ~/.bash_profile"
alias rcbashupdate="source ~/.bashrc"

## Function that will update the terminal
terminal-update() {

    CurrentFolder=$(pwd)
    echo -e "[you are]: $CurrentFolder"
    ProjectFolder=$(getProjectFolder)

    # move to the bash_aliases project folder and execute the upgrade function
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "[moving to]:$ProjectFolder \n"
    fi
    cd "$ProjectFolder" > /dev/null 2>&1

    if [[ "$DEBUG" == "1" ]]; then
        echo -e "[git repository upgrade]: $ProjectFolder \n"
    fi
    git pull origin master > /dev/null 2>&1

    if [[ "$DEBUG" == "1" ]]; then
        echo -e "[upgrade]: starting upgrade of data"
    fi
    zsh ./upgrade.sh

    # this will update the bash
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "\n[updating]:$HOME/.bash_profile"
    fi
    source "$HOME/.bash_profile"

    # back to the previous folder that you're working
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "[back to]: $CurrentFolder"
    fi
    cd "$CurrentFolder" > /dev/null 2>&1

}

## Alias for the terminal update
tu() {
    terminal-update
}

# Directory improvement
alias ..='cd ../'                   # Go back 1 directory level
alias ...='cd ../../'               # Go back 2 directory levels
alias ....='cd ../../../'           # Go back 3 directory levels