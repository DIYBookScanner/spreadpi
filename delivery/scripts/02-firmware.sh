#!/bin/bash
set -e

# Install rpi-update and dependencies
apt-get -y install git-core binutils ca-certificates curl
wget --continue https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update
chmod +x /usr/bin/rpi-update
mkdir -p /lib/modules/3.1.9+
touch /boot/start.elf


# Update kernel and firmware
rpi-update
