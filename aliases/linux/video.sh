#!/bin/bash

# Strubloid::linux::video

increase-audio-in-video() {

  if [ -z "$1" ]
  then
      read -p "Tell me the file to increase audio from it : " video_file
  else
    video_file=$1
  fi

  if [ -z "$2" ]
  then
      read -p "Tell me the destination filename : " destination_file
  else
    destination_file=$2
  fi

  ffmpeg -i "$video_file" -vcodec copy -af "volume=50dB" "$destination_file"

}

## This will be getting a local file and transcribing 
## it to a vtt file using the whisper model
video-transcribe() {

  if [ -z "$1" ]
  then
      read -p "Tell me the file to transcribe from it : " video_file
  else
    video_file=$1
  fi

  local correct_file_path="$(pwd)/$video_file"
  local lang="${2:-en}"

  # checking if the file exists
  if [[ -z "$correct_file_path" ]]; then
    echo "Usage: video-transcribe <video-file> [lang]"
    echo "[File not found]: $correct_file_path"
    return 1
  fi
  
  ## creating the file
  local video_file_transcribed="$(pwd)/$video_file-transcribed.vtt"
  touch "$video_file_transcribed"

  ## populating with the transcription
  "$BASH_ALIASES_VENV_BIN/whisper" "$correct_file_path" --language "$lang" > "$video_file_transcribed"

}