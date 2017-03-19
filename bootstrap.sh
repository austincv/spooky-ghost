#!/usr/bin/env bash

# required memory in KB, if the vm memory is less than this then
# the difference will be added as swap space.
REQUIRED_MEMORY=1572864 # 1.5 GB
START_TIME=$(date)

AVAILABLE_MEMORY=$(sudo cat /proc/meminfo | grep MemTotal: | awk '{print $2}')

echo "
    Available Total memory :${AVAILABLE_MEMORY} kB
    "

if [ "${AVAILABLE_MEMORY}" -lt "${REQUIRED_MEMORY}" ]; then
    SWAP_REQUIRED_KB=$(expr ${REQUIRED_MEMORY} - ${AVAILABLE_MEMORY})
    SWAP_REQUIRED_MB=$(expr ${SWAP_REQUIRED_KB} / 1024)
    echo "
    We require at least :${REQUIRED_MEMORY} kB
    Enabling ${SWAP_REQUIRED_MB} MB Swap space to proceed with installation.
    "
    USE_SWAP=true
fi

# create swap space
if ${USE_SWAP} = true; then
    SWAP_FILE=/var/swapfile
    sudo /usr/bin/fallocate -l ${SWAP_REQUIRED_MB}M ${SWAP_FILE}
    sudo chmod 600 ${SWAP_FILE}
    sudo /sbin/mkswap ${SWAP_FILE}
    sudo /sbin/swapon ${SWAP_FILE}

    # make it permanent
    echo "${SWAP_FILE}           none     swap   sw              0 0" | \
    sudo tee -a /etc/fstab
fi

# Update system
echo "
    Updating system packages ...
"
sudo apt-get update
sudo apt-get -y upgrade

echo 'Start : '${START_TIME}
echo 'End   : '$(date)