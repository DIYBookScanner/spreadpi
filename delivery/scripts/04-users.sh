#!/bin/bash

DELIVERY=/usr/src/delivery

# Create root user
echo "root:raspberry" | chpasswd
cp $DELIVERY/bashrc /root/.bashrc


# Create spreads user
useradd -s /bin/bash -m spreads
echo "spreads:spreads" |chpasswd
cp $DELIVERY/bashrc /home/spreads/.bashrc
