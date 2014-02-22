#!/bin/bash

# Install spreads dependencies
apt-get -y install build-essential cython libffi-dev libjpeg8-dev liblua5.1-0\
            libudev-dev libusb-1.0-0-dev libusb-dev nginx python2.7-dev\
            python-pyexiv2 python-netifaces python-virtualenv python-yaml unzip || exit 1
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip || exit 1
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip || exit 1
rm -rf /tmp/chdkptp.zip || exit 1

su --login --command 'virtualenv ~/virtspreads' spreads

su - spreads

. ~/virtspreads/bin/activate

# Get newest pip version
wget https://raw.github.com/pypa/pip/develop/contrib/get-pip.py
python get-pip.py
pip --version

# Install pythonic dependencies
pip install cffi colorama futures flask flask-compress jpegtran-cffi \
	requests waitress zipstream

# https://github.com/openxc/openxc-python/issues/18
pip install --pre pyusb

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /tmp/spreads
cd /tmp/spreads
git checkout webplugin
python setup.py install

# Install cython-hidapi from GitHub
pip install git+https://github.com/gbishop/cython-hidapi.git

exit

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
