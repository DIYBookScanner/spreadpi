#!/bin/bash
set -e

# Install rpi-update and dependencies
apt-get -y install --no-install-recommends git-core binutils ca-certificates curl
wget --continue https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update
chmod +x /usr/bin/rpi-update
mkdir -p /lib/modules/3.1.9+
touch /boot/start.elf

# Temporarily fake uname output to fix rpi-update
mv /bin/uname /bin/uname.bak
echo '
#\!/bin/sh
echo "3.1.9+"
' > /bin/uname
chmod +x /bin/uname

# Update kernel and firmware
rpi-update

# Restore original uname
mv /bin/uname.bak /bin/uname
