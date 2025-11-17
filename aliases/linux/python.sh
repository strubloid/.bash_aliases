#!/bin/bash

# Strubloid::linux::Python

# # alias gpt-summarizer='/media/games/apps/gpt-summarizer/main_cli.py'
py-start-local(){

  # Check if python3-venv is installed
  if ! dpkg -l | grep -q python3-venv; then
    echo "python3-venv not found. Installing..."
    sudo apt install python3-venv -y
  fi
  
  python3 -m venv venv
  source venv/bin/activate
}

start-python-local(){

  # Check if python3-venv is installed
  if ! dpkg -l | grep -q python3-venv; then
    echo "python3-venv not found. Installing..."
    sudo apt install python3-venv -y
  fi

  python3 -m venv /media/games/apps/pyhtonEnvironment/myenv
  source /media/games/apps/pyhtonEnvironment/myenv/bin/activate  # Activate the virtual environment
}

limit-parameters-python()
{
  ulimit -s 8192
}

unlimit-parameters-python()
{
  ulimit -s 65536
}


gptLocal()
{
  ## getting the current environment
  python_output=$(python3 -c "import sys; print(sys.prefix)")

  # Check if the output is equal to "/usr", so we need update to our own
  if [ "$python_output" == "/usr" ]; then
    start-python-local
  fi

  ## just making sure we have on terminal wide
  export BASH_ALIASES_SCRIPTS="$HOME/.bash_aliases_scripts"
  python3 "$BASH_ALIASES_SCRIPTS/chat-gpt.py" "$1"
}

sum-gpt()
{
    # loading first parameter of the function, if you forgot will have
    ## the option to say what is the word or file
    if [ -z "$1" ]
    then
        read -p "[text or filepath]: " USER_INPUT
    else
        USER_INPUT=$1
    fi

    CURRENT_FOLDER=$(pwd)
    SPLIT_FOLDER="$CURRENT_FOLDER/split"
    GPT_FOLDER="$CURRENT_FOLDER/gpt"

    echo "* $SPLIT_FOLDER"

    ## Creating the export folder for the current folder exported knowledge
    if [[ ! -d $SPLIT_FOLDER ]]; then
        echo "[SPLIT_FOLDER]: CREATED"
        mkdir -p "$SPLIT_FOLDER" > /dev/null 2>&1
    else
      echo "[SPLIT_FOLDER]: OK"
    fi

    ## Creating the export folder for the current folder exported knowledge
    if [[ ! -d $GPT_FOLDER ]]; then
        echo "[GPT_FOLDER]: CREATED"
        mkdir -p "$GPT_FOLDER" > /dev/null 2>&1
    else
      echo "[GPT_FOLDER]: OK"
    fi

    ## This will check if the user input is a file
    ##  throwing all the content of the file inside of the USER_INPUT
    if [[ -f $USER_INPUT ]]; then
        echo "[USER_INPUT]: FILE"
        USER_INPUT=$(cat "$CURRENT_FOLDER/$USER_INPUT")
    fi
    echo "[USER_INPUT]: OK"

    ## Split of the array in 1200 words on each index
#    IFS=$'\n' read -d '' -r -a USER_INPUT_ARRAY <<< "$(echo "$USER_INPUT" | tr ' ' '\n' | awk 'NR%1200==1{x++} {print > "split/user_input_part_" x".txt"} END {print x}')"

    ## Iterating though each file on split folder to normalize files
#    for splitFile in "$SPLIT_FOLDER"/*
#    do
#        ## normalizing file, creating a temp for this and later on move to the current file
#        tempFile=$(mktemp)
#        tr '\n' ' ' < "$splitFile" > "$tempFile"
#        mv -f "$tempFile" "$splitFile" > /dev/null 2>&1
#    done

    ## tentativa de todo o texto


    ## Iterating though each file on export folder
#    index=0
#    for splitFile in "$SPLIT_FOLDER"/*
#    do
      ## Building the question of summarizing it
      ASK_QUESTION="tem como resumir essa historia? $(echo "$USER_INPUT")"

      ## update the $splitFile (for debug purposes)
#      echo "$ASK_QUESTION" > $splitFile

    echo "ASKING GPT"

      ## Running the chatgpt on python
      CHAT_RESPONSE=$(gptLocal "$ASK_QUESTION")
    echo "MAKING GPT FILE chat_gpt_reply.txt"
      ## getting the response from chat-gpt and split to specific text file
#      echo "$CHAT_RESPONSE" > "$GPT_FOLDER/${index}-chat_gpt_reply.txt"
      echo "$CHAT_RESPONSE" > "chat_gpt_reply.txt"

#      ((index++))
#    done

#    echo "Delete Split Folder"
    ## rm -Rf "$SPLIT_FOLDER"

}