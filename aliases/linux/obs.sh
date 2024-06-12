#!/bin/bash

# Strubloid::linux::obs

# Set the source and target directories
function loadObsPluginsRelations()
{
  SOURCE_DIR="/usr/share/obs/obs-plugins"
  TARGET_DIR="/home/$USER/.var/app/com.obsproject.Studio/config/obs-studio/plugins"

  echo "[Started]"

  # Check if the target directory exists; create it if not
  if [ ! -d "$TARGET_DIR" ]; then
      mkdir -p "$TARGET_DIR"
      echo "[$TARGET_DIR]: created folder"
  fi

  # Loop through each plugin folder in the source directory
  for plugin_folder in "$SOURCE_DIR"/*; do
      # Extract the plugin name from the folder path
      plugin_name=$(basename "$plugin_folder")

      # Check if the symbolic link already exists
      if [ ! -e "$TARGET_DIR/$plugin_name" ]; then
          ln -s "$plugin_folder" "$TARGET_DIR/$plugin_name" # Create a symbolic link
          echo "[$plugin_name]: Created "
      fi
  done

  echo "[Finished]"
}
