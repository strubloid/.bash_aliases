#!/bin/bash

# Strubloid::linux::audio

fix-installation()
{
  sudo apt-get install --reinstall alsa-base linux-image-`uname -r` libasound2 alsa-utils alsa-tools
}

fix-audio() {

  ALSABASE="/etc/modprobe.d/alsa-base.conf"
  BLACKLIST="/etc/modprobe.d/blacklist.conf"


  # https://unix.stackexchange.com/questions/248991/alsa-not-detecting-the-good-sound-card
  #  options snd_hda_intel index=0
  #options snd_hda_codec_hdmi index=1
  #options snd_hda_intel index=2
  #options snd_hda_codec_hdmi index=-2
  #alias snd-card-0 snd-hda-intel
  #alias sound-slot-0 snd-hda-intel
  #alias sound-slot-0 snd-card-0

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

  LINE4="blacklist snd_soc_skl"
  if ! grep -qF "$LINE4" "$BLACKLIST"; then
    echo "[+] Adding: $LINE4"
    echo "$LINE4" | sudo tee -a "$BLACKLIST"
  else
      echo "[] - OK"
  fi

  pulseaudio -k && sudo alsa force-reload

#  sudo alsactl init 0

  aplay -lL

}

#reload-audio() {
#  pulseaudio -k && sudo alsa force-reload
#}

reinstall-audio(){
  sudo apt purge alsa-base pulseaudio -y
  sudo apt install alsa-base pulseaudio -y
}

#fix-reload()
#{
#  pulseaudio --start
#}

test-sound()
{
  sudo aplay /usr/share/sounds/alsa/Front_Center.wav
}

# Didnt work
#asundfix()
#{
#  sudo mv /var/lib/alsa/asound.state /var/lib/alsa/asound.state.old
#  sudo alsactl --file /var/lib/alsa/asound.state store
#  sudo alsa force-reload
#  mv  ~/.config/pulse/ ~/.config/pulse_old/
#  pulseaudio -k
#}