#!/bin/bash

# Strubloid::linux::youtube

check-and-install-yt-dlp(){
  if command -v yt-dlp &>/dev/null; then
    echo "yt-dlp is already installed."
    return 0
  fi

  echo "yt-dlp not found. Installing latest binary..."
  sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
  sudo chmod a+rx /usr/local/bin/yt-dlp
}

get-video-subtitle(){
  local url="$1"
  local lang="${2:-en}"

  if [[ -z "$url" ]]; then
    echo "Usage: get-video-subtitle <youtube-url> [lang]"
    echo "  lang defaults to 'en'"
    return 1
  fi

  check-and-install-yt-dlp || return 1

  yt-dlp --write-auto-subs --sub-lang "$lang" --skip-download "$url"
}


