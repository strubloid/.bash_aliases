#!/bin/bash

# Strubloid::linux::ai

## function to start the open web ui

## installing the chat cuda version
chat-install-cuda(){
  if [ -d "$HOME/.bash_aliases_docker/" ]; then
      docker-compose -f $HOME/.bash_aliases_docker/openwebui/cuda/docker-compose.yml up -d
  else
      echo " [ERROR]: Docker-compose  file not found."
  fi  
}

## installing the chat main version
chat-install-main(){

    if [ -d "$HOME/.bash_aliases_docker/" ]; then
        docker-compose -f $HOME/.bash_aliases_docker/openwebui/main/docker-compose.yml up -d
    else
        echo " [ERROR]: Docker-compose  file not found."
    fi
}

# command to update the repo
pull-main-repo(){
  docker pull ghcr.io/open-webui/open-webui:main
}

# command to update the repo
pull-cuda-repo(){
  docker pull ghcr.io/open-webui/open-webui:cuda
}


# Function to start the chatGPT GUI locally with GPU support
chat_start() {
  read -r -p "Do you want to start with CUDA? (y/n): " choice
  if [[ "$choice" =~ ^(yes|y|Y|Yes|YES)$ ]]
  then
    docker-compose -f "$HOME/.bash_aliases_docker/openwebui/cuda/docker-compose.yml" up -d open-webui-cuda
  else 
    docker-compose -f "$HOME/.bash_aliases_docker/openwebui/main/docker-compose.yml" up -d open-webui-main
  fi 
}

# Function to update the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local(){

  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui
  
  # 2. Pull the latest image
  pull-cuda-repo

  # 3. Recreate the container
  chat-install-cuda
}

# Function to start the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local-cpu(){
  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui

  # 2. Pull the latest image
  pull-main-repo

  # 3. Recreate the container
  chat-install-main
}