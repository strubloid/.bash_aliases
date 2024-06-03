#!/bin/bash

# Strubloid::linux::ai


install-chat-gpt-local()
{

  if [ -z "$1" ]
  then
      # shellcheck disable=SC2034
      # read -p "[Folder to install]: " FOLDER_TO_INSTALL
      FOLDER_TO_INSTALL="/media/games/apps/gpt-ui"
  else
      FOLDER_TO_INSTALL=$1
  fi

  docker run -d --network=host -v open-webui:"$FOLDER_TO_INSTALL" -e OLLAMA_BASE_URL=http://127.0.0.1:11434 -name  open-webui --restart always ghcr.io/open-webui/open-webui:main
}


chat-gpt-gui-local()
{
  docker run -d --network=host -v open-webui:/media/games/apps/gpt-ui -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name  open-webui --restart always ghcr.io/open-webui/open-webui:main
}