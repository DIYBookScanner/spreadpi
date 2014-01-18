#!/bin/bash

DELIVERY=/usr/src/delivery


debconf-set-selections /debconf.set
rm -f /debconf.set

# Update packages
cd /usr/src/delivery
apt-get update
apt-get -y upgrade

# Install rpi-update and dependencies
apt-get -y install git-core binutils ca-certificates
wget --continue https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update
chmod +x /usr/bin/rpi-update
mkdir -p /lib/modules/3.1.9+
touch /boot/start.elf

# Update kernel and firmware
rpi-update

# Install some basic tools and libraries
apt-get -y install locales console-common ntp openssh-server less vim zsh

# Create root user
echo "root:raspberry" | chpasswd

# Create spreads user
useradd -s /usr/bin/zsh -m spreads
echo "spreads:spreads" |chpasswd

# Install spreads dependencies
apt-get -y install liblua5.1-0 python-yaml python-pip unzip libusb-dev python-netifaces python-pyexiv2
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
rm -rf /tmp/chdkptp.zip

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /usr/src/spreads
cd /usr/src/spreads
git checkout webplugin
pip install -e .

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

# Setup udev rules
echo 'ACTION=="add", SUBSYSTEM=="usb", MODE:="666"' > /etc/udev/rules.d/99-usb.rules
sed -i -e 's/KERNEL\!="eth\*|/KERNEL\!="/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
