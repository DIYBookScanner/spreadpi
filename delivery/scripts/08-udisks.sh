#! /bin/bash

# User spreads needs to mount usb disks
cp $DELIVERY_DIR/files/55-udisks.pkla /etc/polkit-1/localauthority/50-local.d/
