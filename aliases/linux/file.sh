#!/bin/bash

# Strubloid::linux::basic

## comments out a single line in a file by prepending "# "
function comment-file-line() {
  local file="$1"
  local line="$2"
 
  if [ -z "$file" ] || [ -z "$line" ]; then
    echo "Usage: comment-file-line <file> <line_number>"
    return 1
  fi
 
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    return 1
  fi
 
  sed -i "${line}s/^/# /" "$file"
}
 
## removes the leading "# " (or "#") comment marker from a single line in a file
function uncomment-file-line() {
  local file="$1"
  local line="$2"
 
  if [ -z "$file" ] || [ -z "$line" ]; then
    echo "Usage: uncomment-file-line <file> <line_number>"
    return 1
  fi
 
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    return 1
  fi
 
  sed -i "${line}s/^# *//" "$file"
}