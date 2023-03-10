#!/bin/bash

# Strubloid::linux::firewall

## References:
#
# 1 : https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04
# 2 : https://stackoverflow.com/questions/30251889/how-to-open-some-ports-on-ubuntu
allowingPort()
{
  # Example: sudo ufw allow 8080
  sudo ufw allow "$1"
}

## If you want to open it for a range and for a protocol
## ufw allow 11200:11299/tcp
## ufw allow 11200:11299/udp
allowRangePorts()
{
   sudo ufw allow "$1":"$2"/tcp
   sudo ufw allow "$1":"$2"/udp
}

listenPort()
{
  # Example: nc -l 1701
  nc -l "$1"
}

setupDefaultPolicies()
{
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
}

allowingSSH()
{
  sudo ufw allow ssh
}

allowingHTTPS(){
  sudo ufw allow https
}

allowingHTTP(){
  sudo ufw allow http
}

configureFirewall()
{
  sudo vim /etc/default/ufw
}

checkPorts()
{
  sudo ufw status verbose
}

enableFirewall()
{
  sudo ufw enable
}

allowSpecificIP()
{
  # sudo ufw allow from 54.75.231.100
  sudo ufw allow from "$1"
}

checkNumberRules()
{
  sudo ufw status numbered
}

deleteNumberedRule()
{
  # sudo ufw delete 1
  sudo ufw delete "$1"
}

TCPDUMP-localhost()
{
  sudo tcpdump -nn 'host 127.0.0.1'
}


check-opened-ports()
{
  # sudo lsof -i -P -n | grep LISTEN
  sudo netstat -tulpn | grep LISTEN

}

check-opened-ports-users()
{
  sudo ss -tulpn | grep LISTEN
}

check-port()
{
  sudo lsof -i:$1
}

check-ip()
{
  sudo nmap -sTU -O $1
}