#!/usr/bin/env bash

# required memory in KB, if the vm memory is less than this then
# the difference will be added as swap space.
REQUIRED_MEMORY=2097152 # 2 GB
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
sudo DEBIAN_FRONTEND=noninteractive apt-get -y \
 -o Dpkg::Options::="--force-confdef" \
 -o Dpkg::Options::="--force-confold" dist-upgrade

# Install node and npm
sudo apt-get install -y nodejs nodejs-legacy npm

# Download and install ghost
sudo apt-get install -y unzip
sudo mkdir -p /var/www/
sudo wget https://ghost.org/zip/ghost-latest.zip
sudo unzip -d /var/www/ghost ghost-latest.zip
sudo rm ghost-latest.zip

cd /var/www/ghost
sudo npm install --production

echo 'Start : '${START_TIME}
echo 'End   : '$(date)