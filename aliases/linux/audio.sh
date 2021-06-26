#!/bin/bash

# Strubloid::linux::audio

reload-audio() {
  pulseaudio -k && sudo alsa force-reload
}


