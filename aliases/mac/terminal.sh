#!/bin/zsh

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
    echo -e "[moving to]:$ProjectFolder \n"
    cd "$ProjectFolder"
    echo -e "[git repository upgrade]: $ProjectFolder \n"
    git pull origin master

    echo -e "[upgrade]: starting upgrade of data"
    ./upgrade.sh

    # this will update the bash
    echo -e "\n[updating]:$HOME/.bash_profile"
    source "$HOME/.bash_profile"

    # back to the previous folder that you're working
    echo -e "[back to]: $CurrentFolder"
    cd "$CurrentFolder"

}

## Alias for the terminal update
tu() {
    terminal-update
}

# Directory improvement
alias ..='cd ../'                   # Go back 1 directory level
alias ...='cd ../../'               # Go back 2 directory levels
alias ....='cd ../../../'           # Go back 3 directory levels
alias .3='cd ../../../'             # Go back 3 directory levels
alias .4='cd ../../../../'          # Go back 4 directory levels
alias .5='cd ../../../../../'       # Go back 5 directory levels
alias .6='cd ../../../../../../'    # Go back 6 directory levels

alias bc='bc -l'                    # start the calculator with math support

# main comand list
alias root='sudo -i'                # root alias
alias wget='wget -c'                # this one saved by butt so many times
alias cp='cp -rf'                   # Preferred 'cp' implementation
alias cpc='cp -iv'                   # Preferred 'cp' implementation
alias mv='mv -iv'                   # Preferred 'mv' implementation
alias mkdir='mkdir -pv'             # Preferred 'mkdir' implementation
alias less='less -FSRXc'            # Preferred 'less' implementation
alias ln='ln -i'                    # You need to say 'y' or 'n'
alias edit='subl'                   # edit:         Opens any file in sublime editor
alias which='type -all'             # which:        Find executables
alias path='echo -e ${PATH//:/\\n}' # path:         Echo all executable Paths
mcd() { mkdir -p "$1" && cd "$1"; } # mcd:          Makes new Dir and jumps inside

# Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'