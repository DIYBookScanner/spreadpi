#!/bin/bash
set -e

# Install some basic tools and libraries
apt-get -y install --no-install-recommends cifs-utils console-common htop less ntp openssh-server sudo vim

# User spreads should be able to shut the system down (used in web interface)
echo 'spreads spreadpi = (root) NOPASSWD: /sbin/shutdown' >> /etc/sudoers

# Fix 'unable to resolve host spreadpi' errors
sed -i -e 's/\(127.0.0.1.*\)/\1 spreadpi/g' /etc/hosts
