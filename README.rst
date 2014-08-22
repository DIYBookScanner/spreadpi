.. image:: https://raw.githubusercontent.com/DIYBookScanner/spreadpi/gh-pages/logo_small.jpg

Raspberry Pi image tailored for running a DIYBookScanner with the spreads
software suite.

Based on a script by Andrius Kairiukstis and Klaus M. Pfeiffer:
https://github.com/andrius/build-raspbian-image

Download
========
`Latest Nightly Build <http://buildbot.diybookscanner.org/nightly/spreadpi-latest.img.7z>`_

For older versions, head over to the `Buildbot directory <http://buildbot.diybookscanner.org/nightly/>`_.

Build Requirements
==================
* `git`
* `binfmt_misc` kernel module loaded
* `qemu-arm-static`
* `deboostrap`
* `kpartx`
* `mkfs.vfat`
* `mkfs.ext4`
* raspbain archive key installed

On Debian and derivatives::

    wget http://archive.raspbian.org/raspbian.public.key -O - | sudo apt-key add -

Building
========
To generate an image, run the `build.sh` script as root:

::

    $ sudo ./build.sh
    
There are some environment variables that you can set to customize the build:

`IMAGESIZE`
    Target size for the image in MB (default: `2000`)
`BOOTSIZE`
    Size of the `/boot` partition in MB (default: `64`)
`DEB_RELEASE`
    Target Raspbian release, can be `stable`, `testing` or `unstable` (default: `stable`)
`DEFAULT_DEB_MIRROR`
    Repository URL to grab packages from (default: `http://mirrordirector.raspbian.org/raspbian`)
`USE_LOCAL_MIRROR`
    For use with `apt-cacher-ng`, can be `true` or `false` (default: `false`)
`SSH_KEY`
    Public key to enable SSH Login for (default: `~/.ssh/id_rsa.pub`)
`DEBUG`
    Drop into a chroot shell after the image has finished building (default: `false`)

The image will generate a rasbpian image with up-to-date packages and spreads
pre-installed and pre-configured (for use with Canon A2200 cameras running CHDK).
On the first boot, the image will resize itself to fill all of the remaining space
on the SD-Card and reboot shortly thereafter.
Spreads will be automatically launched on startup. Make sure that your devices
are turned on before the boot has finished.

Login accounts:
    * root:raspberry
    * spreads:spreads
    
The `spreads` user is allowed to run all commands with superuser privileges through `sudo`.
