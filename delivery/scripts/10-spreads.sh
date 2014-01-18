#!/bin/bash

DELIVERY=/usr/src/delivery

# Install spreads dependencies
apt-get -y install liblua5.1-0 libusb-dev nginx python-netifaces python-pip  python-pyexiv2 python-yaml unzip
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
rm -rf /tmp/chdkptp.zip

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /usr/src/spreads
cd /usr/src/spreads
git checkout webplugin
pip install flask flask-compress zipstream waitress requests
pip install -e .

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

