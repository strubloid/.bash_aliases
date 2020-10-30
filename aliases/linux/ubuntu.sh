#!/bin/bash

# Strubloid::linux::ubuntu

function fix-network() {
    # lshw -C network
    sudo modprobe -r ath10k_pci && sudo modprobe ath10k_pci
    ## check file  ~/bin/resetWireless
}

## Reference: https://www.cyberciti.biz/faq/how-to-install-networked-hp-printer-and-scanner-on-ubuntu-linux/
function install-hp-deskJet-2600()
{
    ## Install of the hplib and hplib-gui
    sudo apt install hplip hplip-gui

    ## Setup for the printer
    if [ -n "$1" ]; then
        hp-setup $1
    else
        printf "Do you want to specify an IP ?\n[Y or N]: "
        read addIpQuestion
        if [ "$addIpQuestion" == "Y" ] || [ "$addIpQuestion" == "y" ]
        then
            printf "IP: "
            read ipPrinter
            hp-setup "$ipPrinter"
        else
            printf "Using default IP: 192.168.0.115"
            hp-setup 192.168.0.115
        fi
    fi

}
