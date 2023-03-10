#!/bin/sh

# Strubloid::linux::root #!/bin/sh


# This will be checking the disk usage on the server and saving into
# a logfile
CR() {


# "HISTIGNORE" means to not save this command into the history.
export HISTIGNORE='*sudo -S*'
#echo "r@f@1234" | sudo -S -v
#sudo whoami

echo "r@f@1234" | sudo -S -v
echo 3 | sudo tee /proc/sys/vm/drop_caches

#cat ~/.password | sudo -S -i << 'EOF'
#    echo "Now i am $(whoami) - UP?"
#    echo "$(id)"
#    echo 3 > '/proc/sys/vm/drop_caches'
#EOF

#cat ~/.password | sudo -S -i <<EOF
#    echo "Now i am $(whoami) - 2"
#    echo "$(id)"
#    echo 3 > '/proc/sys/vm/drop_caches'
#EOF


#if [ "root" != "$USER" ]; then
#  su -c "$0" root
#
#sudo -i <<'EOF'
#    echo "Now i am $(whoami) - UP?"
#    echo "$(id)"
#    echo 3 > '/proc/sys/vm/drop_caches'
#EOF
#  whoami
#fi


# SET PASSWORD
#my_password='r@f@1234'

#sudo -kSs << EOF
#r@f@1234
#whoami
#echo "Not a good idea to have a password encoded in plain text"
#EOF


## INVOKE sudo WITH PASSWORD
#echo "$my_password" | sudo -KSs su;
#
## INVOKE COMMANDS WITH ROOT ACCESS
#echo "$my_password"| sudo -S 'whoami'

#sudo -kS -i << 'EOF'
#    echo "Now i am $(whoami) - UP?"
#    echo "$(id)"
#    echo 3 > '/proc/sys/vm/drop_caches'
#EOF
#
#
#
#echo "$my_password" | su - root -c "my command line"
#
#expect -c 'spawn su - otheruser -c "my command line"; expect "Password :"; send "<otherpwd>\n"; interact'








## Save the password in the hidden file
#echo "[Password] Update file"
#echo 'r"f"1234' > ~/.password
#
## Pass the password over STDIN to sudo
#echo "[Root] Login"
#cat ~/.password | sudo -S su
#
#
#echo "[Clean] cache"
#echo 3 >'/proc/sys/vm/drop_caches'
#
##  echo 3 | sudo tee /proc/sys/vm/drop_caches
##  action "[Root] Login"


#echo 'r"f"1234' | sudo -S -u root -c "sudo su - && echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && echo 'running as root, you must print $USER'"
#su -c "sudo su - && echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && echo 'running as root, you must print $USER' " root


#  sudo su -
#  echo 3 > /proc/sys/vm/drop_caches

echo "[Cache] - Clean"
#  action "[Cache] - Clean"
#  exit

#  swapoff -a
#  create-4G-Swap
#  swapon -a
#  action "[Swap] - Clean"

#  su -c "sudo su - && echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && echo 'running as root, you must print $USER' " root

#  echo 3 >'/proc/sys/vm/drop_caches'
#  swapoff -a && swapon -a

#  echo "running as root, you must print $USER"
#  echo "pwd"
#  pwd

#  echo 'jfdsaf7$TDgf' | su -S -c "echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a" root
#  su -c "echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'" root
}
