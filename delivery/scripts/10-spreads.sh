#!/bin/bash
set -e

# Install spreads dependencies
if [ -e $DELIVERY_DIR/spreads-sdist.tar.gz ]; then
    apt-get -y --force-yes install --no-install-recommends \
        chdkptp python python-colorama python-yaml python-concurrent.futures \
        python-blinker python-roman python-usb python-psutil \
        python-jpegtran python-hidapi-cffi python-isbnlib python-flask \
        python-requests python-wand python-zipstream python-netifaces \
        python-dbus liblua5.2-dev libusb-dev
    apt-get -y install python-pip build-essential python2.7-dev pkg-config
    pip install tornado
    pip install lupa --install-option="--no-luajit"
    pip install $DELIVERY_DIR/spreads-sdist.tar.gz
    apt-get -y remove --purge --auto-remove build-essential
else
    apt-get -y --force-yes install spreads spreads-web chdkptp
fi

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

# Install spreads init script
cp $DELIVERY_DIR/files/spread /etc/init.d/spread
chmod a+x /etc/init.d/spread

# Add spreads init script to default boot sequence
update-rc.d spread defaults
