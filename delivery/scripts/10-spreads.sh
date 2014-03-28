#!/bin/bash

# Exit from script if any command returns a non-zero exit status
# See https://stackoverflow.com/questions/3474526/stop-on-first-error .
set -e

echo "Installing spreads debian package dependencies..."
apt-get -y install build-essential libdbus-1-dev libdbus-glib-1-dev\
            libffi-dev libjpeg8-dev liblua5.1-0 libudev-dev\
            libusb-1.0-0-dev libusb-dev libusbhid-common libyaml-dev\
            nginx python2.7-dev python-dbus python-virtualenv unzip

echo "Installing chdkptp..."
wget --continue https://www.assembla.com/spaces/chdkptp/documents/aH1W4CQbmr46hcacwqjQYw/download/aH1W4CQbmr46hcacwqjQYw -O /tmp/chdkptp.zip
unzip -d /usr/local/lib/chdkptp /tmp/chdkptp.zip
# User spreads should be able to use chdkptp...
chmod -R 755 /usr/local/lib/chdkptp/
rm -rf /tmp/chdkptp.zip

echo "Installing libhidapi-libusb..."
cd /tmp
wget http://buildbot.diybookscanner.eu/libhidapi-libusb0_0.8.0~rc1%2bgit20140201.3a66d4e%2bdfsg-2_armhf.deb
dpkg -i libhidapi-libusb0_0.8.0~rc1+git20140201.3a66d4e+dfsg-2_armhf.deb
rm -rf libhidapi-libusb0_0.8.0~rc1+git20140201.3a66d4e+dfsg-2_armhf.deb

echo "Installing all things python as non-root user spreads in a virtualenv..."
su --login --command "$DELIVERY_DIR/files/install_spreads.sh" spreads

echo "Creating spreads configuration directory..."
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads
chown -R spreads:spreads /home/spreads/.config/spreads

echo "Making sure that everything file in ~spreads has correct ownership set..."
shopt -s dotglob
cd /home/spreads && chown -R spreads:spreads *
shopt -u dotglob

echo "Installing spreads init script..."
cp $DELIVERY_DIR/files/spread /etc/init.d/spread
chmod a+x /etc/init.d/spread

echo "Adding spreads init script to default boot sequence..."
update-rc.d spread defaults

echo "Installing nginx configuration..."
cp $DELIVERY_DIR/files/nginx_default /etc/nginx/sites-enabled/default
chmod a+x /etc/nginx/sites-enabled/default

echo "Adding nginx init script to default boot sequence..."
update-rc.d nginx defaults

echo "Creating spreads logfile..."
mkdir -p /var/log/spreads
touch /var/log/spreads/spread.log
chown -R spreads:spreads /var/log/spreads
