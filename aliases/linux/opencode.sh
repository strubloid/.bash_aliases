#!/bin/bash

# Strubloid::linux::opencode

opencode-chrome() {
  local path="${1:-.}"
  local port="${2:-9999}"
  cd "$path" && opencode serve --hostname 0.0.0.0 --port "$port"
}

opencode-kill() {
  local port="${1:-9999}"
  echo "Killing process on port $port..."
  fuser -k "$port"/tcp 2>/dev/null || pkill -f "opencode serve.*$port" || echo "No process found on port $port"
}

