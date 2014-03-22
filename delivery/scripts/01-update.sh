#!/bin/bash

debconf-set-selections /debconf.set || exit 1
rm -f /debconf.set || exit 1

# Update packages
cd /usr/src/delivery || exit 1
apt-get update || exit 1
apt-get -y upgrade || exit 1
apt-get -y install wget -t jessie
