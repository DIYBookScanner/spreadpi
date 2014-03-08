#!/bin/bash

# Install some basic tools and libraries
apt-get -y install console-common htop less locales nginx ntp openssh-server sudo vim || exit 1

echo 'spreads spreadpi = (root) NOPASSWD: /sbin/shutdown' >> /etc/sudoers
