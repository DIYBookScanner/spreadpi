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
* `binfmt` kernel module loaded
* `qemu-arm-static`
* `deboostrap`
* `kpartx`
* `lvm2`
* `dosfstools`
* raspbain archive key installed

On Debian and derivatives::

    sudo apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools
    wget http://archive.raspbian.org/raspbian.public.key -O - | sudo apt-key add -


Usage
=====
The build script has to be run as root

::

    $ sudo ./build.sh
