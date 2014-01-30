#!/bin/bash

# Install spreads dependencies
apt-get -y install build-essential cython libffi-dev libjpeg8-dev liblua5.1-0\
            libudev-dev libusb-1.0-0-dev libusb-dev nginx python2.7-dev\
            python-pyexiv2 python-netifaces python-pip python-yaml unzip || exit 1
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip || exit 1
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip || exit 1
rm -rf /tmp/chdkptp.zip || exit 1

# Get newest pip version


# Install CFFI
pip install cffi || exit 1

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /usr/src/spreads || exit 1
cd /usr/src/spreads || exit 1
git checkout webplugin || exit 1
pip install flask flask-compress zipstream waitress requests jpegtran-cffi || exit 1
pip install -e "." || exit 1
# TODO: the following two commands always fail
pip install -e ".[chdkcamera]"
pip install -e ".[web]"

# Install cython-hidapi from GitHub
pip install git+https://github.com/gbishop/cython-hidapi.git || exit 1

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads || exit 1
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads || exit 1
chown -R spreads /home/spreads/.config/spreads || exit 1

# Install spreads init script
cp $DELIVERY_DIR/files/spread /etc/init.d/spread || exit 1
chmod a+x /etc/init.d/spread || exit 1

# Add spreads init script to default boot sequence
update-rc.d spread defaults || exit 1

# Install nginx configuration
cp $DELIVERY_DIR/files/nginx_default /etc/nginx/sites-enabled/default || exit 1
chmod a+x /etc/nginx/sites-enabled/default || exit 1

# Add nginx init script to default boot sequence
update-rc.d nginx defaults || exit 1
