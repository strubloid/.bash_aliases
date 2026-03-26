#!/bin/bash

# Strubloid::linux::ai

## function to start the open web ui
chat-gpt-gui(){
  docker start open-webui
}

chat-install-cuda(){
    docker run -d \
               -p 3000:8080 \
              --name open-webui \
              --add-host=host.docker.internal:host-gateway \
              -e OLLAMA_BASE_URL=http://host.docker.internal:11434 ghcr.io/open-webui/open-webui:cuda

}

chat-install-main(){
    docker run -d \
               -p 3000:8080 \
              --name open-webui \
              --add-host=host.docker.internal:host-gateway \
              -e OLLAMA_BASE_URL=http://host.docker.internal:11434 ghcr.io/open-webui/open-webui:main

}

pull-main-repo(){
  docker pull ghcr.io/open-webui/open-webui:main
}


pull-cuda-repo(){
  docker pull ghcr.io/open-webui/open-webui:cuda
}
# Function to start the chatGPT GUI locally with GPU support
chat-gpt-gui-local()
{
  if docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
    echo "Container exists. Starting..."
    docker start open-webui
  else
    chat-install-cuda
  fi
}

# Function to update the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local(){

  docker rm -f open-webui                         # 1. Stop and remove the container (data in the volume is preserved)
  docker pull ghcr.io/open-webui/open-webui:cuda  # 2. Pull the latest image

  # 3. Recreate the container
  chat-install-cuda
}

# Function to start the chatGPT GUI locally without GPU support
chat-gpt-gui-local-cpu()
{
    if docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
    echo "Container exists. Starting..."
    docker start open-webui
  else
    chat-install-main
  fi
  
}

# Function to start the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local-cpu(){
  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui

  # 2. Pull the latest image
  docker pull ghcr.io/open-webui/open-webui:main

  # 3. Recreate the container
  chat-install-main
}