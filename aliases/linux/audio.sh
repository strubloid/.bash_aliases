#!/bin/bash

# Strubloid::linux::audio

## this will fix the hdmi not found sometimes when sound isn't there, you must just run this command
##  and it will be fixed.
fix-hdmi(){
  sudo killall pulseaudio; rm -rf ~/.config/pulse/* ; rm -rf ~/.pulse*
}

# References
# https://unix.stackexchange.com/questions/248991/alsa-not-detecting-the-good-sound-card
# https://askubuntu.com/questions/1115671/blueman-protocol-not-available
fix-audio(){

  echo "[Audio] Fixing the audio v2"

  echo "[Purge] alsa-base pulseaudio pulseaudio-module-bluetooth  "
  sudo apt purge alsa-base pulseaudio pulseaudio-module-bluetooth   -y

  echo "[Re-innstall] alsa-base pulseaudio"
  sudo apt install alsa-base pulseaudio pulseaudio-module-bluetooth  -y

  ALSABASE="/etc/modprobe.d/alsa-base.conf"
  echo "[Configure]: $ALSABASE"

  LINE1="options snd-hda-intel model=generic"
  if ! grep -qF "$LINE1" "$ALSABASE"; then
    echo "[+] Adding: $LINE1"
    echo "$LINE1" | sudo tee -a "$ALSABASE"
  else
    echo "[] - OK"
  fi

  LINE2="options snd-hda-intel dmic_detect=0"
  if ! grep -qF "$LINE2" "$ALSABASE"; then
    echo "[+] Adding: $LINE2"
    echo "$LINE2" | sudo tee -a "$ALSABASE"
  else
      echo "[] - OK"
  fi

  LINE3="options snd-hda-intel model=dell-headset-multi"
  if ! grep -qF "$LINE3" "$ALSABASE"; then
    echo "[+] Adding: $LINE3"
    echo "$LINE3" | sudo tee -a "$ALSABASE"
  else
      echo "[] - OK"
  fi

  BLACKLIST="/etc/modprobe.d/blacklist.conf"
  echo "[Configure]: $BLACKLIST"

  LINE4="blacklist snd_soc_skl"
  if ! grep -qF "$LINE4" "$BLACKLIST"; then
    echo "[+] Adding: $LINE4"
    echo "$LINE4" | sudo tee -a "$BLACKLIST"
  else
      echo "[] - OK"
  fi

  echo "[HDMI FIX]: Remove previous setup on ~/config/pulse and ~/.pulse"
  rm -rf ~/.config/pulse/* && rm -rf ~/.pulse*

  echo "[Kill process]: pulseaudio"
  pulseaudio -k

  echo "[Reload]: alsa"
  sudo alsa force-reload

  echo "[Apply]: new alsa configuration"
  aplay -lL

  echo "[Bluettoth]: Install/load module"
  sudo apt-get install pulseaudio-module-bluetooth
  pactl load-module module-bluetooth-discover

}

test-sound()
{
  sudo aplay /usr/share/sounds/alsa/Front_Center.wav
}