#!/bin/bash

# Strubloid::linux::bluetooth

## References: https://techwiser.com/fix-bluetooth-device-doesnt-auto-connect-in-linux/
auto-connect-bluetooth() {

  ## going to the user home
  cd ~

  # clone of the repository
  git clone https://github.com/jrouleau/bluetooth-autoconnect.git

  ## At home we will copy the configuration to the /etc/systemd/system
  sudo cp ~/bluetooth-autoconnect/bluetooth-autoconnect.service /etc/systemd/system/

  ## creating the binary
  sudo cp ~/bluetooth-autoconnect/bluetooth-autoconnect /usr/bin/

  ## Enabling the service
  sudo systemctl enable bluetooth-autoconnect.service

  ## starting the service
  sudo systemctl start bluetooth-autoconnect.service


}