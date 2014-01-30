#!/bin/bash
locale-gen --purge en_US.UTF-8 || exit 1
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale || exit 1
