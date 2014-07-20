#!/bin/bash
set -e

cp /usr/src/delivery/files/resizepart_once /etc/init.d/resizepart_once
cp /usr/src/delivery/files/resize2fs_once /etc/init.d/resize2fs_once
chmod +x /etc/init.d/resizepart_once
chmod +x /etc/init.d/resize2fs_once
update-rc.d resizepart_once defaults
