#!/bin/bash

# Strubloid::linux::ai


install-chat-gpt-local()
{

  if [ -z "$1" ]
  then
      # shellcheck disable=SC2034
      # read -p "[Folder to install]: " FOLDER_TO_INSTALL
      FOLDER_TO_INSTALL="~/apps/gpt-ui"
  else
      FOLDER_TO_INSTALL=$1
  fi

  docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:"$FOLDER_TO_INSTALL" --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
}


chat-gpt-gui-local()
{
  docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:~/apps/gpt-ui --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
}