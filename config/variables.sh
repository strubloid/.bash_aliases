#!/bin/bash

## home folder
HOME_FOLDER=$(echo $HOME)

## .bash_aliases file path
HOME_ALIASES="${HOME_FOLDER}/.bash_aliases"

## bashrc file path
BASHRC="${HOME_FOLDER}/.bashrc"

BASH_ALIASES_LINE="
## installed by .install.sh
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi"

EXPORTEDFILE='.bash_aliases_export'