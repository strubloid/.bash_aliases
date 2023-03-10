#!/bin/bash

# Strubloid::general::terminal

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

#   -----------------------------------------------------
#   This is a function to search for a word in a folder
#   The main command is:
#
#   grep -R /var/www/html search_for | awk '{split($0,a,"[/]"); print a[1]"/"a[2]"/"a[3]"/"a[4]"/"a[5]}' | uniq
#   -----------------------------------------------------
search-word() {

    if [ -z "$1" ]; then
        echo "You must specify what is the word to search"
    else
        if [ -z "$2" ]; then
            echo "You must specify the place to search"
        else
            grep -R $2 $1 | awk '{split($0,a,"[/]"); print a[1]"/"a[2]"/"a[3]"/"a[4]"/"a[5]}' | uniq
        fi
    fi
}

change-extension() {

    if [ -z "$1" ]; then
        until read -r -p "Folder (Mandatory): " folder && test "$folder" != ""; do
            continue
        done
    else
        folder=$1
    fi

    if [ -z "$2" ]; then
        until read -r -p "Extension From (Mandatory): " extensionFrom && test "$extensionFrom" != ""; do
            continue
        done
    else
        extensionFrom=$2
    fi

    if [ -z "$3" ]; then
        until read -r -p "Extension To (Mandatory): " extensionTo && test "$extensionTo" != ""; do
            continue
        done
    else
        extensionTo=$3
    fi

    #  find ./src -depth -name "*.js" -exec rename 's/\.js$/.jsx/' {} +
    find "$folder" -depth -name "*.$extensionFrom" -exec rename 's/\.'$extensionFrom'$/.'$extensionTo'/' {} +
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

zipf() { zip -r "$1".zip "$1"; }       # zipf:         To create a ZIP archive of a folder
alias numFiles='echo $(ls -1 | wc -l)' # numFiles:     Count of non-hidden files in current dir
alias make1mb='mkfile 1m ./1MB.dat'    # make1mb:      Creates a file of 1mb size (all zeros)
alias make5mb='mkfile 5m ./5MB.dat'    # make5mb:      Creates a file of 5mb size (all zeros)
alias make10mb='mkfile 10m ./10MB.dat' # make10mb:     Creates a file of 10mb size (all zeros)

# extract:  Extract most know archives with one command
extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# qfind:    Quickly search for file
alias qfind="find . -name "

# ff:       Find file under the current directory
ff() { /usr/bin/find . -name "$@"; }

# ffs:      Find file whose name starts with a given string
ffs() { /usr/bin/find . -name "$@"'*'; }

# ffe:      Find file whose name ends with a given string
ffe() { /usr/bin/find . -name '*'"$@"; }

#   findPid: find out the pid of a specified process
#   -----------------------------------------------------------
#   Ex: findPid '/d$/'
#   it will find pids of all processes with names ending in 'd'
#   -----------------------------------------------------------
findPid() { lsof -t -c "$@"; }

#   Find memory hogs
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

# my_ps: List processes owned by my user:
my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command; }

alias ports='netstat -tulanp'     # show open ports
# alias ping='ping -c 5'            # Stop after sending count ECHO_REQUEST packets
# alias fastping='ping -c 100 -s.2' # Do not wait interval 1 second, go fast
