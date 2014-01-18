#!/bin/bash

debconf-set-selections /debconf.set
rm -f /debconf.set

# Update packages
cd /usr/src/delivery
apt-get update
apt-get -y upgrade
