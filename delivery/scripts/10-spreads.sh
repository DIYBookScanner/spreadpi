#!/bin/bash
set -e

# Install spreads dependencies
apt-get -y install build-essential libffi-dev libjpeg8-dev liblua5.2-0\
           libudev-dev libusb-1.0-0-dev libusb-dev nginx python2.7-dev\
           python-netifaces python-pip python-yaml unzip python-dbus
wget http://jbaiter.de/files/hidapi/libhidapi-libusb0_0.8.0~rc1+git20140201.3a66d4e+dfsg-2_armhf.deb -O /tmp/libhidapi.deb
dpkg -i /tmp/libhidapi.deb
rm -f /tmp/libhidapi.deb
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
rm -rf /tmp/chdkptp.zip

# Install CFFI
pip install cffi

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git -b postprocessing_api /usr/src/spreads
pip install -e /usr/src/spreads
pip install -e /usr/src/spreads[chdkcamera]
pip install -e /usr/src/spreads[hidtrigger]
pip install -e /usr/src/spreads[web]

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

# Install spreads init script
cp $DELIVERY_DIR/files/spread /etc/init.d/spread
chmod a+x /etc/init.d/spread

# Add spreads init script to default boot sequence
update-rc.d spread defaults

# Install nginx configuration
cp $DELIVERY_DIR/files/nginx_default /etc/nginx/sites-enabled/default
chmod a+x /etc/nginx/sites-enabled/default

# Add nginx init script to default boot sequence
update-rc.d nginx defaults
