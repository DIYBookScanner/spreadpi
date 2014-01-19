::

                                  _       _
     ___ _ __  _ __ ___  __ _  __| |_ __ (_)
    / __| '_ \| '__/ _ \/ _` |/ _` | '_ \| |
    \__ \ |_) | | |  __/ (_| | (_| | |_) | |
    |___/ .__/|_|  \___|\__,_|\__,_| .__/|_|
        |_|                        |_|


Raspberry Pi image tailored for running a DIYBookScanner with the spreads
software suite.

Based on a script by Andrius Kairiukstis and Klaus M. Pfeiffer:
https://github.com/andrius/build-raspbian-image

Requirements
============
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

Usage
=====
To generate an image, run the `build.sh` script as root:

::

    $ sudo ./build.sh

The image will generate a rasbpian image with up-to-date packages and spreads
with the currently experimental webinterface pre-installed and pre-configured
(for use with Canon A2200 cameras running CHDK). Spreads will be automatically
launched on startup. Make sure that your devices are turned on before the boot
has finished.

Login accounts:
    * root:raspberry
    * spreads:spreads
