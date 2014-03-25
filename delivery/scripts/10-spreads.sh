#!/bin/bash

# Exit from script if any command returns a non-zero exit status
# See https://stackoverflow.com/questions/3474526/stop-on-first-error .
set -e

# Install spreads dependencies
apt-get -y install build-essential libdbus-1-dev libdbus-glib-1-dev\
            libffi-dev libjpeg8-dev liblua5.1-0 libudev-dev\
            libusb-1.0-0-dev libusb-dev libusbhid-common libyaml-dev\
             nginx python2.7-dev python-virtualenv unzip

# Chdkptp
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aH1W4CQbmr46hcacwqjQYw/download/aH1W4CQbmr46hcacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
# User spreads should be able to use chdkptp...
chmod -R 755 /usr/local/lib/chdkptp/
rm -rf /tmp/chdkptp.zip

# Pythin dbus bindings need to be installed through configure/make/make install
mkdir -p /tmp/python-dbus
wget http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.2.0.tar.gz -o /tmp/python-dbus/dbus-python-1.2.0.tar.gz
cd /tmp/python-dbus
tar zxvf *.tar.gz
./configure --prefix /home/spreads/virtspreads/local/
make
make install
cd /tmp
rm -rf /tmp/python-dbus

# Hidapi-hidraw
cd /tmp
git clone git://github.com/signal11/hidapi.git
cd hidapi/linux
mv Makefile-manual Makefile
make
cp libhidapi-hidraw.so /usr/lib/libhidapi-hidraw.so.0
cd /tmp
rm -rf /tmp/hidapi

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
