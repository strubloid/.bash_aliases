#!/bin/bash

# Strubloid::linux::wsl

# Remove any existing subl alias so the function can be defined
unalias subl 2>/dev/null

subl(){

    # Check if we are in a WSL environment
    if ! grep -qi microsoft /proc/version 2>/dev/null && ! uname -r 2>/dev/null | grep -qi microsoft; then
        echo "Not running in a WSL environment, skipping."
        return 1
    fi

    # Find the Linux subl binary by checking known paths (skip Windows /mnt/c/)
    local subl_path=""
    local search_paths=("/usr/bin/subl" "/usr/local/bin/subl" "/snap/bin/subl" "/opt/sublime_text/sublime_text")

    for p in "${search_paths[@]}"; do
        if [[ -x "$p" ]]; then
            subl_path="$p"
            break
        fi
    done

    if [[ -z "$subl_path" ]]; then
        echo "Sublime Text is not installed in WSL. Installing..."

        # Install the GPG key and repository
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y sublime-text

        for p in "${search_paths[@]}"; do
            if [[ -x "$p" ]]; then
                subl_path="$p"
                break
            fi
        done

        if [[ -z "$subl_path" ]]; then
            echo "Failed to install Sublime Text."
            return 1
        fi

        echo "Sublime Text installed successfully."
    fi

    # Run the Linux subl binary with any passed arguments
    "$subl_path" "$@"

}