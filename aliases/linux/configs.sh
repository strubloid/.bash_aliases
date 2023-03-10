#!/bin/bash

# Strubloid::linux::configs

# Function that will check if you are a sudor user already
isSudorUser()
{
    local prompt
    prompt=$(sudo -nv 2>&1)

    if [ $? -eq 0 ]; then
        echo 1
    elif echo $prompt | grep -q '^sudo:'; then
        echo 0
    else
        echo 1
    fi
}

windowSudo()
{

    ## This will check if you need to provide the sudo password
    sudoUser=$(isSudorUser)
    if [[ $sudoUser == 1 ]]; then
        return 1
    fi

    ## starting the first screen of add your sudo user password
    if [ "$(id -nu)" != "root" ]; then
        sudo -k
        pass=$(whiptail --backtitle "Super Cow User Screen" \
                        --title "Authentication is required :)" \
                        --passwordbox "To run this procees it is necessary to have super cow privileges. \n\n[sudo] Password for user $USER:" 12 60 3>&2 2>&1 1>&3-)

        exitstatus=$?

        ## This will check if was canceled the action or not
        if [ $exitstatus = 0 ]; then

            ## This will run the actual command
            sudo -S -p '' "$0" "$@" <<< "$pass"
            sudo su -
        else
            ## This will show that you pressed the cancel action
            whiptail --title "Cancel" --msgbox "Operation Cancel" 10 60
        fi

    fi
}
