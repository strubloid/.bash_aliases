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

## same youtube subtitle function but for local video file
get-local-video-subtitle(){
  local file="$(pwd)/$1"
  local lang="${2:-en}"

  if [[ -z "$file" ]]; then
    echo "Usage: get-local-video-subtitle <video-file> [lang]"
    echo "  lang defaults to 'en'"
    return 1
  fi

  ## creating the file
  touch "transcribed.vtt"

  ## populating with the transcription
  "$BASH_ALIASES_VENV_BIN/whisper" "$file" --language "$lang" > "transcribed.vtt"
}

# function to get the summary of a youtube video using the subtitle 
# file and openai api
# Usage: get-youtube-video-summary
get-youtube-video-summary(){

  echo "[Youtube Video Summary]"

  # Find the first .vtt file in the current folder
  local vtt_file
  vtt_file=$(find . -maxdepth 1 -name "*.vtt" | head -n 1)

  if [[ -z "$vtt_file" ]]; then
    echo "Error: no .vtt file found in the current directory."
    echo "Run get-video-subtitle first to download subtitles."
    return 1
  fi

  # echo "Using subtitle file: $vtt_file"

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

  # Check for --from argument in the input and extract only the value
  local from_arg=""
  local next_is_value=0
  for arg in "$@"; do
    if [[ $next_is_value -eq 1 ]]; then
      from_arg="$arg"
      break
    fi
    if [[ "$arg" == --from=* ]]; then
      from_arg="${arg#--from=}"
      break
    elif [[ "$arg" == --from ]]; then
      next_is_value=1
    fi
  done

  # echo "Running summary script with from_arg: $from_arg"

  if [[ -n "$from_arg" ]]; then
    "$venv_path/bin/python3" "$BASH_ALIASES_SCRIPTS/chat-gpt-resume.py" "$vtt_file" --from "$from_arg"
  else
    "$venv_path/bin/python3" "$BASH_ALIASES_SCRIPTS/chat-gpt-resume.py" "$vtt_file"
  fi
  
}
