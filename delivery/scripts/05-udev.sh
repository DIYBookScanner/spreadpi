#!/bin/bash

# Setup udev rules
echo 'ACTION=="add", SUBSYSTEM=="usb", MODE:="666"' > /etc/udev/rules.d/99-usb.rules || exit 1
sed -i -e 's/KERNEL\!="eth\*|/KERNEL\!="/' /lib/udev/rules.d/75-persistent-net-generator.rules || exit 1
rm -f /etc/udev/rules.d/70-persistent-net.rules || exit 1
