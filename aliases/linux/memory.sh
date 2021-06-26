#!/bin/bash

# Strubloid::linux::memory

# At least 6 GB memory (RAM): tame the inode cache
function memory-tweak-inode() {

TWEAKINODE=$(cat << END
# Improve cache management
vm.vfs_cache_pressure=50
END
)

sudo /bin/su -c "echo '$TWEAKINODE' >> /etc/sysctl.conf"

}

