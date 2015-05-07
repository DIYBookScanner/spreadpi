#!/bin/bash
set -e

cp $DELIVERY_DIR/files/resize_sd /usr/bin/resize_sd
chmod +x /usr/bin/resize_sd

cp $DELIVERY_DIR/files/resize_sd.service /etc/systemd/system/
systemctl enable resize_sd
