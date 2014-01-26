#!/bin/bash

DELIVERY=/usr/src/delivery

# Install spreads dependencies
apt-get -y install build-essential libffi-dev libjpeg8-dev liblua5.1-0\
            libudev-dev libusb-1.0-0-dev libusb-dev nginx python2.7-dev cython\
            python-netifaces python-yaml unzip
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
rm -rf /tmp/chdkptp.zip

# Get newest pip version
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O/tmp/get-pip.py
python /tmp/get-pip.py

# Install CFFI
pip install cffi

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /usr/src/spreads
cd /usr/src/spreads
git checkout webplugin
pip install -e "."
pip install -e ".[chdkcamera]"
pip install -e ".[web]"

# Install cython-hidapi from GitHub
pip install git+https://github.com/gbishop/cython-hidapi.git

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

# Install spreads init script
cp $DELIVERY/files/spread /etc/init.d/spread
chmod a+x /etc/init.d/spread

# Add spreads init script to default boot sequence
update-rc.d spread defaults

# Install nginx configuration
cp $DELIVERY/files/nginx_default /etc/nginx/sites-enabled/default
chmod a+x /etc/nginx/sites-enabled/default

# Add nginx init script to default boot sequence
update-rc.d nginx defaults
