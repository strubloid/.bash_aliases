#!/bin/bash

# Strubloid::general::dev-container

function devcontainer-enter() {
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