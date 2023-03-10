#!/bin/bash

# Strubloid::linux::java

# missing: JAVA_INCLUDE_PATH JAVA_INCLUDE_PATH2 JAVA_AWT_INCLUDE_PATH

install-jdk()
{
  ## Installation and export
  # sudo apt-get install -y openjdk-17-jdk default-jdk
  sudo apt-get install -y openjdk-8-jdk
  sudo apt-get install -y default-jdk
  sudo update-alternatives --config java

  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
}
