#!/bin/zsh

# Strubloid::linux::mining
SEND_MONEY_HERE_ETH=$(loadEnvData SEND_MONEY_HERE_ETH)
OLD_WALLET_ETH=$(loadEnvData OLD_WALLET_ETH)
NEW_WALLET_ETH=$SEND_MONEY_HERE_ETH

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

  sed -i "s/${OLD_WALLET_ETH}/${NEW_WALLET_ETH}/g" mine_eth.sh

}

# This will start the miner for the lol
s-miner-lol()
{
  cd ~/wallets/1.38
  ./mine_eth.sh
}