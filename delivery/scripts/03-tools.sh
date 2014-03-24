#!/bin/bash

# Install some basic tools and libraries
apt-get -y install cifs-utils console-common htop less locales nginx ntp openssh-server sudo vim || exit 1

# User spreads should be able to shut the system down (used in web interface)
echo 'spreads spreadpi = (root) NOPASSWD: /sbin/shutdown' >> /etc/sudoers
