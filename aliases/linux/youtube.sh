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

# function to get the summary of a youtube video using the subtitle 
# file and openai api
# Usage: get-youtube-video-summary
get-youtube-video-summary(){

  echo "GET SUMMARY V1"

  # Find the first .vtt file in the current folder
  local vtt_file
  vtt_file=$(find . -maxdepth 1 -name "*.vtt" | head -n 1)

  if [[ -z "$vtt_file" ]]; then
    echo "Error: no .vtt file found in the current directory."
    echo "Run get-video-subtitle first to download subtitles."
    return 1
  fi

  echo "Using subtitle file: $vtt_file"

  if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: OPENAI_API_KEY is not set."
    echo "Export it first: export OPENAI_API_KEY='sk-...'"
    return 1
  fi

  export BASH_ALIASES_SCRIPTS="$HOME/.bash_aliases_scripts"
  local venv_path="$BASH_ALIASES_SCRIPTS/.venv"

  # Create venv and install openai if not already set up
  if [[ ! -f "$venv_path/bin/python3" ]]; then
    echo "Creating virtual environment at $venv_path..."
    python3 -m venv "$venv_path"
    "$venv_path/bin/pip" install --quiet openai
  fi

  "$venv_path/bin/python3" "$BASH_ALIASES_SCRIPTS/chat-gpt-resume.py" "$vtt_file"
}
