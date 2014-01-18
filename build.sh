#!/bin/bash

# you need at least
# apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

VERSION="0.1"

# =================== #
#    CONFIGURATION    #
# =================== #

# Size of target SD card in MB
IMAGESIZE="2000"
# Size of /boot partition
BOOTSIZE="64M"
# Debian version
DEB_RELEASE="wheezy"
DEFAULT_DEB_MIRROR="http://mirrordirector.raspbian.org/raspbian"

# Whether to use a local debian mirror (e.g. via 'apt-cacher-ng')
USE_LOCAL_MIRROR=false
LOCAL_DEB_MIRROR="http://localhost:3142/archive.raspbian.org/raspbian"

# Path to build directory, by default a temporary directory
BUILD_ENV=$(mktemp -d)

# When true, script will drop into a chroot shell at the end to inspect the
# bootstrapped system
DEBUG=false

# -------------------------------------------------------------------------- #

echo "" > $SCRIPT_DIR/build.log

if $USE_LOCAL_MIRROR; then
    DEB_MIRROR=$LOCAL_DEB_MIRROR
else
    DEB_MIRROR=$DEFAULT_DEB_MIRROR
fi

if [ ${EUID} -ne 0 ]; then
  echo "this tool must be run as root"
  exit 1
fi

SCRIPT_DIR=$(readlink -m $(dirname $0))
DELIVERY_DIR=$SCRIPT_DIR/delivery
LOG=$SCRIPT_DIR/build.log

rootfs="${BUILD_ENV}/rootfs"
bootfs="${rootfs}/boot"

mkdir -p ${BUILD_ENV}

echo "Creating raw image file"
# Create image file
image="${SCRIPT_DIR}/spreadpi_v${VERSION}.img"
dd if=/dev/zero of=${image} bs=1MB count=$IMAGESIZE &>> $LOG
device=`losetup -f --show ${image}` &>> $LOG
echo "Image ${image} created and mounted as ${device}"

# Setup up /boot and /root partitions
echo "
n
p
1

+${BOOTSIZE}
t
c
n
p
2


w
" | fdisk ${device} &>> $LOG


# Set up loopback devices
losetup -d ${device} &>> $LOG
device=`kpartx -va ${image} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
device="/dev/mapper/${device}"
bootp=${device}p1
rootp=${device}p2

# Create file systems
mkfs.vfat ${bootp} &>> $LOG
mkfs.ext4 ${rootp} &>> $LOG

# Create directory structure
mkdir -p ${rootfs}

mount ${rootp} ${rootfs}

mkdir -p ${rootfs}/proc
mkdir -p ${rootfs}/sys
mkdir -p ${rootfs}/dev
mkdir -p ${rootfs}/dev/pts
mkdir -p ${rootfs}/usr/src/delivery

# Mount pseudo file systems
mount -t proc none ${rootfs}/proc
mount -t sysfs none ${rootfs}/sys
mount -o bind /dev ${rootfs}/dev
mount -o bind /dev/pts ${rootfs}/dev/pts

# Mount our delivery path
mount -o bind ${DELIVERY_DIR} ${rootfs}/usr/src/delivery

cd ${rootfs}


# First stage of bootstrapping, from the outside
echo "Running debootstrap first stage"
debootstrap --verbose --foreign --arch armhf --keyring /etc/apt/trusted.gpg ${DEB_RELEASE} ${rootfs} ${DEB_MIRROR} &>> $LOG


# Second stage, using chroot and qemu-arm from the inside
cp /usr/bin/qemu-arm-static usr/bin/
echo "Running debootstrap second stage"
LANG=C chroot ${rootfs} /debootstrap/debootstrap --second-stage &>> $LOG

mount ${bootp} ${bootfs}

# Configure Debian release and mirror
echo "deb ${DEB_MIRROR} ${DEB_RELEASE} main contrib non-free
" > etc/apt/sources.list

# Configure Raspberry Pi boot options
echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" > boot/cmdline.txt

# Set up mount points
echo "proc            /proc           proc    defaults        0       0
/dev/mmcblk0p1  /boot           vfat    defaults        0       0
" > etc/fstab

# Configure Hostname
echo "spreadpi" > etc/hostname

# Configure networking
echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
" > etc/network/interfaces


# Configure loading of proprietary kernel modules
echo "vchiq
snd_bcm2835
" >> etc/modules

# TODO: What does this do?
echo "console-common	console-data/keymap/policy	select	Select keymap from full list
console-common	console-data/keymap/full	select	us
" > debconf.set

# Run user-defined scripts from DELIVERY_DIR/scripts
echo "Running custom bootstrapping scripts"
for script in usr/src/delivery/scripts/*; do
    echo "/$(basename $script)"
    LANG=C chroot ${rootfs} /$script &>> $LOG
done

# Configure default mirror
echo "deb ${DEFAULT_DEB_MIRROR} ${DEB_RELEASE} main contrib non-free
" > etc/apt/sources.list


# Clean up
echo "Cleaning up bootstrapped system"
echo "#!/bin/bash
aptitude update
aptitude clean
apt-get clean
rm -f cleanup
" > cleanup
chmod +x cleanup
LANG=C chroot ${rootfs} /cleanup &>> $LOG

cd ${rootfs}

if $DEBUG; then
    echo "Dropping into shell"
    LANG=C chroot ${rootfs} /bin/bash
fi

# Synchronize file systems and unmount
sync
sleep 15
umount -l ${bootp}
umount -l ${rootfs}/usr/src/delivery
umount -l ${rootfs}/dev/pts
umount -l ${rootfs}/dev
umount -l ${rootfs}/sys
umount -l ${rootfs}/proc
umount -l ${rootfs}
umount -l ${rootp}

echo "Finishing ${image}"

# Remove partition mappings
kpartx -d ${image} &>> $LOG

echo "Created image ${image}"
