#!/bin/bash

# Strubloid::linux::zrok

## Step 1: Install zrok
zrok-install() {
  curl -sSf https://get.openziti.io/install.bash | sudo bash -s zrok2
}

## step 2: enable zrok environment
# enable-zrok-env key-from-zrok 
# Enabling zrok environment with account token...
# ⣻  the zrok environment was successfully enabled...
zrok-enable-env() {
  
  local accountToken="${1:-}"
  
  if [[ -z "$accountToken" ]]; then
    echo "Error: Account token is required to enable zrok environment."
    return 1
  fi

  echo "[Zrok]: Enabling zrok environment with account token..."
  zrok2 enable "$accountToken"
}

## Step 3: configure the endpoint
zrok-endpoint-configure() {
  local endpointName="${1:-https://api-v1.zrok.io}"
  zrok2 config set apiEndpoint "$endpointName"
  echo "[Zrok]: Endpoint configured: $endpointName"
}

## Step 4: Start zrok server
zrok-server-start() {
  local port="${1:-8080}"
  echo "[Zrok]: Starting zrok server on port $port..."
  zrok2 server --port "$port" &
  echo "[Zrok]: Zrok server started on port $port"
}

## Step 5: Share a public directory or project
zrok-sharing-project() {
  local project="${1:-.}"
  local log_file="/tmp/zrok-last.log"

  rm -f "$log_file"

  echo "[Zrok]: Sharing project: $project..."
  echo "[Zrok]: Saving zrok output to: $log_file"

  script -q -f -c "zrok2 share public '$project'" "$log_file"
}

## This will retrieve the last shared project URL from the zrok log file
zrok-project-url() {
  local domain

  domain="$(
    tr -d '\r' < /tmp/zrok-last.log |
      grep -oE '[a-zA-Z0-9.-]+\.shares\.zrok\.io' |
      tail -n 1
  )"

  if [[ -z "$domain" ]]; then
    echo "[Zrok]: No zrok URL found in /tmp/zrok-last.log"
    return 1
  fi

  echo "https://$domain"
  ## grep -oE '[a-zA-Z0-9.-]+\.shares\.zrok\.io' /tmp/zrok-last.log | tail -n 1
}

## this can be used to check the status of the zrok server
zrok-status() {
  echo "[Zrok]: Checking zrok server status..."
  zrok2 status
}