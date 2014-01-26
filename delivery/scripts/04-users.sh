#!/bin/bash

# Create root user
echo "root:raspberry" | chpasswd
cp $DELIVERY_DIR/bashrc /root/.bashrc


# Create spreads user
useradd -s /bin/bash -m spreads
echo "spreads:spreads" |chpasswd
cp $DELIVERY_DIR/bashrc /home/spreads/.bashrc
mkdir -p /home/spreads/.ssh
cp "$SSH_KEY" /home/spreads/.ssh/authorized_keys
