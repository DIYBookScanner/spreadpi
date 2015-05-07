#!/bin/bash
set -e

# Install spreads dependencies
if [ -e $DELIVERY_DIR/spreads-sdist.tar.gz ]; then
    apt-get -y --force-yes install --no-install-recommends \
        chdkptp python python-colorama python-yaml python-concurrent.futures \
        python-blinker python-roman python-usb python-psutil \
        python-hidapi-cffi python-isbnlib python-flask \
        python-requests python-wand python-zipstream python-netifaces \
        python-dbus liblua5.2-dev libusb-dev python-cffi libjpeg8-dev \
        libturbojpeg1-dev
    apt-get -y install python-pip build-essential python2.7-dev pkg-config
    pip install tornado
    pip install jpegtran-cffi
    pip install lupa --install-option="--no-luajit"
    pip install chdkptp.py
    pip install $DELIVERY_DIR/spreads-sdist.tar.gz
    apt-get -y remove --purge --auto-remove build-essential
else
    apt-get -y --force-yes install spreads spreads-web chdkptp
fi

# Create spreads configuration directoy
mkdir -p /home/spreads/.config/spreads
cp $DELIVERY_DIR/files/config.yaml /home/spreads/.config/spreads
chown -R spreads /home/spreads/.config/spreads

# Install spreads systemd service
cp $DELIVERY_DIR/files/spreads.service /etc/systemd/system/
systemctl enable spreads
