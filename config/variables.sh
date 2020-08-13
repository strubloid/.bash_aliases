#!/bin/bash

## home folder
HOME_FOLDER=$(echo $HOME)

## .bash_aliases file path
export HOME_ALIASES="${HOME_FOLDER}/.bash_aliases"
export HOME_PROFILE="${HOME_FOLDER}/.bash_profile"
export HOME_PROMPT="${HOME_FOLDER}/.bash_prompt"

## bashrc file path
export BASHRC="${HOME_FOLDER}/.bashrc"

export BASH_ALIASES_LINE=$(cat << END
## installed by strubloid
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
END
)

export BASH_PROMPT_LINE=$(cat << END
## installed by strubloid
if [ -f ~/.bash_prompt ]; then
    . ~/.bash_prompt
fi
END
)

export GIT_COMPLETION_LINE=$(cat << END
## installed by strubloid
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
END
)

export BASH_TEMPORARY_F='bash_temp'
export FILESTOREAD='files_to_read.txt'
