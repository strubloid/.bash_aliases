#!/bin/bash

# Strubloid::linux::youtube

# this will check if exist the yt-dlp and if doesn't it will install it for you
check-and-install-yt-dlp(){

  # check if yt-dlp is already installed
  if command -v yt-dlp &>/dev/null; then
    echo "yt-dlp is already installed."
    return 0
  fi

  echo "yt-dlp not found. Installing latest binary..."
  sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
  sudo chmod a+rx /usr/local/bin/yt-dlp
}

# function to get the subtitle of a youtube video using yt-dlp
# Usage: get-video-subtitle <youtube-url> [lang]
# lang defaults to 'en'
# Example: get-video-subtitle https://www.youtube.com/watch?v=pl3HDYmdZKM pt
get-video-subtitle(){
  local url="$1"
  local lang="${2:-en}"

  if [[ -z "$url" ]]; then
    echo "Usage: get-video-subtitle <youtube-url> [lang]"
    echo "  lang defaults to 'en'"
    return 1
  fi

  # here we check if exist the yt-dlp and if doesn't it will install it for you
  check-and-install-yt-dlp || return 1

  yt-dlp --write-auto-subs --sub-lang "$lang" --skip-download "$url"
}


