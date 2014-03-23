#!/bin/bash

# Install rpi-update and dependencies
apt-get -y install curl git-core binutils ca-certificates || exit 1
curl -L https://raw.github.com/Hexxeh/rpi-update/master/rpi-update --output /usr/bin/rpi-update || exit 1
chmod +x /usr/bin/rpi-update || exit 1
mkdir -p /lib/modules/3.1.9+ || exit 1
touch /boot/start.elf || exit 1

# Update kernel and firmware
rpi-update || exit 1
