#!/bin/bash

## .bash_aliases file path
export HOME_ALIASES="$HOME/.bash_aliases"
export HOME_PROFILE="$HOME/.bash_profile"
export HOME_VARIABLES="$HOME/.bash_variables"
export HOME_PROMPT="$HOME/.bash_prompt"
export BASHRC="$HOME/.bashrc"
export BASH_TEMPORARY_F='bash_temp'
export BASH_ALIASES_PROJECT_FOLDER=$(pwd)

export BASH_GLOBAL_LINE=$(cat << END
## installed by strubloid
if [ -f ~/.bash_global ]; then
    . ~/.bash_global
fi
END
)

export BASH_VARIABLES_LINE=$(cat << END
## installed by strubloid
if [ -f ~/.bash_variables ]; then
    . ~/.bash_variables
fi
END
)


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
