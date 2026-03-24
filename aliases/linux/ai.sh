#!/bin/bash

# Strubloid::linux::ai

# Function to start the chatGPT GUI locally with GPU support
chat-gpt-gui-local()
{
  docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
}

# Function to start the chatGPT GUI locally without GPU support
chat-gpt-gui-local-cpu()
{
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
}