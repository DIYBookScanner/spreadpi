#!/bin/bash
set -e

# Create root user
echo "root:raspberry" | chpasswd
cp "$DELIVERY_DIR/files/bashrc" /root/.bashrc


# Create spreads user
useradd -s /bin/bash -m spreads
echo "spreads:spreads" |chpasswd
cp "$DELIVERY_DIR/files/bashrc" /home/spreads/.bashrc
mkdir -p /home/spreads/.ssh

if [ -e "$SSH_KEY" ]; then
    cp "$SSH_KEY" /home/spreads/.ssh/authorized_keys
fi
