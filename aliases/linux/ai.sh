#!/bin/bash

# Strubloid::linux::ai

# Function to start the chatGPT GUI locally with GPU support
chat-gpt-gui-local()
{
  docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
}

# Function to update the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local(){
  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui

  # 2. Pull the latest image
  docker pull ghcr.io/open-webui/open-webui:main

  # 3. Recreate the container
  docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
}

# Function to start the chatGPT GUI locally without GPU support
chat-gpt-gui-local-cpu()
{
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
}

# Function to start the chatGPT GUI locally with GPU support
update-chat-gpt-gui-local-cpu(){
  # 1. Stop and remove the container (data in the volume is preserved)
  docker rm -f open-webui

  # 2. Pull the latest image
  docker pull ghcr.io/open-webui/open-webui:main

  # 3. Recreate the container
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
}