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