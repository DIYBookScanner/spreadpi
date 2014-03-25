#!/bin/bash

# Install some basic tools and libraries
apt-get -y install console-common htop less locales nginx ntp openssh-server sudo vim || exit 1
apt-get install --no-install-recommends cifs-utils

# User spreads should be able to shut the system down (used in web interface)
echo 'spreads spreadpi = (root) NOPASSWD: /sbin/shutdown' >> /etc/sudoers
