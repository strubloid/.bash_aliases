# Debian aliases
alias update='sudo apt-get update && sudo apt-get upgrade'
alias apt-get="sudo apt-get"
alias aptitudey="sudo aptitude -y"
alias aptitude="sudo aptitude"
alias updatey="sudo apt-get --yes"

# changing the system blacklight
alias rafael-monitor-low="sudo sh -c 'echo 30 > /sys/class/backlight/nvidia_0/brightness'"
alias rafael-monitor-medium="sudo sh -c 'echo 50 > /sys/class/backlight/nvidia_0/brightness'"
alias rafael-monitor-high="sudo sh -c 'echo 80 > /sys/class/backlight/nvidia_0/brightness'"

# checking linux errors
alias rafael-linux-errors="journalctl -f -n 0"

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

# handy short cuts #
alias h='history'
alias j='jobs -l'
alias diff='colordiff'                # install colordiff package
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'          # get GPU ram on desktop / laptop
alias update-java="sudo update-alternatives --config java"             # alias for java


## Manjaro Aliases

## Pacman
alias apt2-i='sudo pacman -S'       # install of a package
alias apt2-r='sudo pacman -Rs'      # removing a package
alias apt2-s='sudo pacman -Ss'      # search of a package
alias apt2-up='sudo pacman -Syu'    # package upgrade

## remove mirrors that are failing
alias apt2-up-mirrors="sudo pacman-mirrors -g && sudo pacman -Syy && sync"

## upgrade the debtap
alias debtap-u="sudo debtap -u"


## Rafa tips
alias rafa-memory-available="cat /proc/meminfo"
alias rafa-memory-availablew="watch -n 3 cat /proc/meminfo"

alias rafa-memory-free="free -m"
alias rafa-memory-freew="watch -n 3 free -m"

alias rafa-buffers-clean="sync"
alias rafa-buffers-cleanw="watch -n 900 sync"

## how to get the current X?
alias rafa-current-x="cat /etc/X11/default-display-manager"

alias restart-x1="sudo /etc/init.d/gdm3 restart"
# alias restart-x2="sudo systemctl restart gdm.service"
alias restart-x3="sudo service gdm3 restart"
alias restart-x4="dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'"

### ways to restart the X
# sudo /etc/init.d/gdm3 restart
# systemctl restart gdm.service
# sudo service gdm3 restart
# dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'