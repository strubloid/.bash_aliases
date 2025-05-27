#!/bin/bash

# Strubloid::linux::alienware

# https://ubuntu.forumming.com/question/8104/install-ubuntu-on-alienware-15-r4
# basic ubuntu installation of drivers for your
install-r4-good-drivers()
{
  sudo ubuntu-drivers autoinstall
}


# Did you have the same issue, the ACPI errors?
# If so, my current solution is the followings.
# 1. Set "acpi=off" when booting to install Ubuntu 18.10. (this solution worked for kernel Linux 4.18 or newer as far as I am concerned)
# 2. Set a boot parameter "acpi=noirq". This solves the problems of freezing at booting and rebooting while battery, fan and some other hardware can still be detected by the system ("acpi=off" do not allow battery etc. to be detected, and you might notice that the fan runs like a sinusoidal function). However, the keyboard might not be functioning.
# 3. Set boot parameters "acpi_backlight=vendor" before and after "acpi=noirq", which looks like "acpi_backlight=vendor acpi=noirq acpi_backlight=vendor". This helps the keyboard get functioning.
# Problems still exist using the above tricks, for example, minor issue with the audio, system never returns when close and re-open the lid and some other unknown issues. This is never a perfect solution.
# I still think that the issue would be Linux does not support the very new hardware in m15 or the BIOS. If you get new solutions, please share. Cheers!
# References: https://stackoverflow.com/questions/51047978/cmake-could-not-find-jni
#           : https://stackoverflow.com/questions/16263556/installing-java-7-on-ubuntu/16263651
#           :

alienFx()
{
  # sudo apt-get install -y openjdk-17-jdk default-jdk
  # sudo apt-get install -y default-jdk
  # sudo update-alternatives --config java

  # export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
  # https://github.com/bchretien/AlienFxLite

  # mkdir build && cd build
  # cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local"
  # make
  # make install

  # if your user has USB rights:
  # By directly using the jar file:
  # java -jar AlienFX.jar

  # sudo update-alternatives --config java
  # sudo update-alternatives --config javac
  # sudo update-alternatives --config javaws

  ## Or by using the generated script:
  # alienfx-lite

  ## else:

  ## By directly using the jar file:
  # sudo java -jar AlienFX.jar

  # Or by using the generated script:
  # sudo alienfx-lite
  ls
}
