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

## Start a local server that i can see in my local network
py-local-run(){

  py-start-local

  # export FLASK_APP=app.py
  export FLASK_DEBUG=1
  export FLASK_RUN_HOST=0.0.0.0
  export FLASK_RUN_PORT=5000

  # uncomment the following line to set to development mode
  # export FLASK_ENV=development

  # flask run --host=0.0.0.0 --port=5000
  flask run
}

start-python-local(){

  ## reference to keep
  ## python3 -m venv /media/games/apps/pyhtonEnvironment/myenv
  ## source /media/games/apps/pyhtonEnvironment/myenv/bin/activate

  # Check if python3-venv is installed
  if ! dpkg -l | grep -q python3-venv; then
    echo "python3-venv not found. Installing..."
    sudo apt install python3-venv -y
  fi

  # Get current directory
  CURRENT_DIR=$(pwd)
  DEFAULT_VENV_PATH="$CURRENT_DIR/python-env/myenv"

  # Check if python-env folder exists in current directory
  if [ -d "$CURRENT_DIR/python-env" ]; then
    read -p "Use existing python-env in current directory? [Y/n]: " USE_LOCAL
    USE_LOCAL=${USE_LOCAL:-Y}  # Default to Y if user just presses enter
    
    if [[ "$USE_LOCAL" =~ ^[Yy]$ ]]; then
      VENV_PATH="$DEFAULT_VENV_PATH"
    else
      read -p "Enter path for python environment (will create [path]/python-env/myenv): " CUSTOM_PATH
      # Handle empty input - default to current directory
      if [ -z "$CUSTOM_PATH" ]; then
        VENV_PATH="$DEFAULT_VENV_PATH"
      else
        # Expand ~ and resolve to absolute path
        CUSTOM_PATH="${CUSTOM_PATH/#\~/$HOME}"
        CUSTOM_PATH=$(realpath -m "$CUSTOM_PATH")
        VENV_PATH="$CUSTOM_PATH/python-env/myenv"
      fi
    fi
  else
    read -p "Create python environment at current directory? [Y/n]: " CREATE_LOCAL
    CREATE_LOCAL=${CREATE_LOCAL:-Y}  # Default to Y if user just presses enter
    
    if [[ "$CREATE_LOCAL" =~ ^[Yy]$ ]]; then
      VENV_PATH="$DEFAULT_VENV_PATH"
    else
      read -p "Enter path for python environment (will create [path]/python-env/myenv): " CUSTOM_PATH
      # Handle empty input - default to current directory
      if [ -z "$CUSTOM_PATH" ]; then
        VENV_PATH="$DEFAULT_VENV_PATH"
      else
        # Expand ~ and resolve to absolute path
        CUSTOM_PATH="${CUSTOM_PATH/#\~/$HOME}"
        CUSTOM_PATH=$(realpath -m "$CUSTOM_PATH")
        VENV_PATH="$CUSTOM_PATH/python-env/myenv"
      fi
    fi
  fi

  echo "Creating/using virtual environment at: $VENV_PATH"
  
  # Check if venv already exists
  if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/activate" ]; then
    echo "Virtual environment already exists, activating..."
    source "$VENV_PATH/bin/activate"
  else
    # Create the directory if it doesn't exist
    VENV_DIR=$(dirname "$VENV_PATH")
    if [ ! -d "$VENV_DIR" ]; then
      echo "Creating directory: $VENV_DIR"
      mkdir -p "$VENV_DIR"
    fi
    
    # Create virtual environment
    if python3 -m venv "$VENV_PATH"; then
      echo "Virtual environment created successfully"
      source "$VENV_PATH/bin/activate"
    else
      echo "Error: Failed to create virtual environment"
      return 1
    fi
  fi
}

py-install-requirements(){
  # Check if virtual environment is activated
  if [ -z "$VIRTUAL_ENV" ]; then
    echo "Warning: No virtual environment is activated"
    read -p "Do you want to activate start-python-local first? [Y/n]: " ACTIVATE_VENV
    ACTIVATE_VENV=${ACTIVATE_VENV:-Y}
    
    if [[ "$ACTIVATE_VENV" =~ ^[Yy]$ ]]; then
      start-python-local
    else
      echo "Proceeding without virtual environment..."
    fi
  fi

  # Check if requirements.txt exists in current directory
  if [ -f "requirements.txt" ]; then
    echo "Installing packages from: requirements.txt"
    if pip install -r requirements.txt; then
      echo "Successfully installed requirements"
    else
      echo "Error: Failed to install requirements"
      return 1
    fi
  else
    # requirements.txt not found
    read -p "requirements.txt not found. Install packages with 'pip install -e .'? [Y/n]: " USE_EDITABLE
    USE_EDITABLE=${USE_EDITABLE:-Y}
    
    if [[ "$USE_EDITABLE" =~ ^[Yy]$ ]]; then
      echo "Installing package in editable mode..."
      if pip install -e .; then
        echo "Successfully installed package"
      else
        echo "Error: Failed to install package"
        return 1
      fi
    else
      echo "Installation cancelled"
      return 1
    fi
  fi
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