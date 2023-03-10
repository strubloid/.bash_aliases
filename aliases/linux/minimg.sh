#!/bin/bash

# Strubloid::linux::mining
RAFAEL_ETH=0x3B97FB923009Bd6A63d950FF359181C6Bd480995

# references: https://www.youtube.com/watch?v=Covog93AweA
i-amd-basic()
{
  # cd ~ && mkdir mining-amd && cd ~/mining-amd

  # Download of the main driver
  wget --referer=http://support.amd.com https://drivers.amd.com/drivers/linux/amdgpu-pro-21.30-1290604-ubuntu-20.04.tar.xz
}

# Reference: https://linuxconfig.org/how-to-install-cuda-on-ubuntu-20-04-focal-fossa-linux
i-intel-nvidia-basic()
{
  sudo apt update && sudo apt install nvidia-cuda-toolkit

}

# reference:https://linuxconfig.org/ethereum-mining-on-ubuntu-18-04-and-debian
i-wallets()
{
  cd ~ && mkdir wallets && cd ~/wallets

  wget https://cutt.ly/YT8hpX6 -O PhoenixMiner_5.9d_Linux.zip
  unzip PhoenixMiner_5.9d_Linux.zip

  cd ~/wallets/PhoenixMiner_5.9d_Linux
  chmod +x PhoenixMiner && chmod +x *.sh

  cd ~/wallets/
  wget https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.38/lolMiner_v1.38_Lin64.tar.gz
  tar -xvf lolMiner_v1.38_Lin64.tar.gz

  cd ~/wallets/1.38
  chmod +x lolMiner && chmod +x *.sh

  sed -i 's/0x155da78b788ab54bea1340c10a5422a8ae88142f/0x3B97FB923009Bd6A63d950FF359181C6Bd480995/g' mine_eth.sh

}

# This will start the miner for the lol
s-miner-lol()
{
  cd ~/wallets/1.38
  ./mine_eth.sh
}