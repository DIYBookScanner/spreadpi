#!/bin/bash

# Exit from script if any command returns a non-zero exit status
# See https://stackoverflow.com/questions/3474526/stop-on-first-error .
set -e

# Install spreads dependencies
apt-get -y install build-essential libffi-dev libjpeg8-dev liblua5.1-0\
            libudev-dev libusb-1.0-0-dev libusb-dev libyaml-dev nginx\
            python2.7-dev python-virtualenv unzip
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aDDsvQyhOr465JacwqjQYw/download/aDDsvQyhOr465JacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
# User spreads should be able to use chdkptp...
chmod -R 755 /usr/local/lib/chdkptp/
rm -rf /tmp/chdkptp.zip

# Install all things python as non-root user "spreads" in a virtualenv.
su --login --command "$DELIVERY_DIR/files/install_spreads.sh" spreads

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads
chown -R spreads:spreads /home/spreads/.config/spreads

# Make sure that everything file in ~spreads has correct ownership set
shopt -s dotglob
cd /home/spreads && chown -R spreads:spreads *
shopt -u dotglob

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

# Create spreads logfile
mkdir -p /var/log/spreads
touch /var/log/spreads/spread.log
chown -R spreads:spreads /var/log/spreads
