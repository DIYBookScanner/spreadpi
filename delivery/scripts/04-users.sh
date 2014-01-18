#!/bin/bash

# Create root user
echo "root:raspberry" | chpasswd

# Create spreads user
useradd -s /usr/bin/zsh -m spreads
echo "spreads:spreads" |chpasswd

