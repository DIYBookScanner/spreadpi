#!/bin/bash
set -e

cp $DELIVERY_DIR/files/spreadpi_init /usr/bin/
chmod +x /usr/bin/spreadpi_init

cp $DELIVERY_DIR/files/spreadpi.service /etc/systemd/system/
systemctl enable spreadpi
