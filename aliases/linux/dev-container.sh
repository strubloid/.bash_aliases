#!/bin/bash

# Strubloid::general::dev-container

## This will be entering the container with specific name
function devcontainer-enter-container-name() {
  local container_name="$1"

  if [ -z "$container_name" ]; then
    echo "Usage: devcontainer-enter <container_name>"
    return 1
  fi

  local container_id
  container_id=$(docker ps --filter "name=$container_name" --format "{{.ID}}")

  if [ -z "$container_id" ]; then
    echo "No running container found with name: $container_name"
    return 1
  fi

  docker exec -it "$container_id" /bin/bash
}

# This will be entering the dev container local folder
# You will be able to enter the machine with bash as terminal
function devcontainer-enter(){
  devcontainer exec --workspace-folder . bash
}