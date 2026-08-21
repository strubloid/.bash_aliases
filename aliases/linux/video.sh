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

video-transcribe() {

  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ffmpeg not found. Installing..."
    sudo apt install ffmpeg -y
  fi

  if [ -z "$1" ]
  then
      read -p "Tell me the file to transcribe from it : " video_file
  else
    video_file=$1
  fi

  local correct_file_path="$(pwd)/$video_file"
  local lang="${2:-en}"

  if [[ ! -f "$correct_file_path" ]]; then
    echo "Usage: video-transcribe <video-file> [lang]"
    echo "[File not found]: $correct_file_path"
    return 1
  fi

  local video_file_transcribed="$(pwd)/$video_file-transcribed.vtt"
  local out_dir="$(dirname "$video_file_transcribed")"
  touch "$video_file_transcribed"

  local total_duration
  total_duration=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$correct_file_path" 2>/dev/null)

  echo "[INFO] Transcribing video file: $correct_file_path to $video_file_transcribed"

  "$BASH_ALIASES_VENV_BIN/whisper" "$correct_file_path" \
    --language "$lang" \
    --verbose True \
    --output_format vtt \
    --output_dir "$out_dir" 2>&1 | \
    awk -v total="$total_duration" '
      {
        if (match($0, /^\[[0-9:.]+ --> ([0-9:.]+)\]/)) {
          end_ts = substr($0, RSTART, RLENGTH)
          sub(/^\[/, "", end_ts); sub(/\]$/, "", end_ts)
          split(end_ts, parts, " --> ")
          split(parts[2], t, ":")
          secs = t[1]*3600 + t[2]*60 + t[3]
          if (total + 0 > 0) {
            pct = (secs / total) * 100
            if (pct > 100) pct = 100
            printf "\r[INFO] Progress: %5.1f%%", pct
            fflush()
          }
        }
      }
      END { printf "\n" }
    '

  local whisper_generated="$out_dir/$(basename "${correct_file_path%.*}").vtt"
  if [[ -f "$whisper_generated" && "$whisper_generated" != "$video_file_transcribed" ]]; then
    mv "$whisper_generated" "$video_file_transcribed"
  fi

  echo "[INFO] Done: $video_file_transcribed"
}