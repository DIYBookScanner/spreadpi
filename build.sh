#!/bin/bash

# Try to get version string from Git
VERSION=$(git tag -l --contains HEAD)
if [ -z "$RELEASE" ]; then
    # We append a random number, since otherwise our loopback devices will
    # be broken on multiple runs if we use the same image name each time.
    VERSION="git@$(git log --pretty=format:'%h' -n 1)_$RANDOM"
fi

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
USE_LOCAL_MIRROR=true
LOCAL_DEB_MIRROR="http://localhost:3142/archive.raspbian.org/raspbian"

# Path to build directory, by default a temporary directory
BUILD_ENV=$(mktemp -d)

# When true, script will drop into a chroot shell at the end to inspect the
# bootstrapped system
DEBUG=false

# Path to authorized SSH key, exported for scripts/04-users
export SSH_KEY=~/.ssh/id_rsa.pub

# -------------------------------------------------------------------------- #

echo "" > $SCRIPT_DIR/buildlog_$VERSION.txt

if $USE_LOCAL_MIRROR; then
    DEB_MIRROR=$LOCAL_DEB_MIRROR
else
    DEB_MIRROR=$DEFAULT_DEB_MIRROR
fi

if [ ${EUID} -ne 0 ]; then
  echo "this tool must be run as root"
  exit 1
fi

# Install dependencies
for dep in binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools; do
  problem=$(dpkg -s $dep|grep installed)
  echo Checking for $dep: $problem
  if [ "" == "$problem" ]; then
    echo "No $dep. Setting up $dep"
    apt-get --force-yes --yes install $dep
  fi
done

# Install raspbian key
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -

SCRIPT_DIR=$(readlink -m $(dirname $0))
LOG=$SCRIPT_DIR/buildlog_$VERSION.txt

# Exported to subshells
export DELIVERY_DIR=$SCRIPT_DIR/delivery

rootfs="${BUILD_ENV}/rootfs"
bootfs="${rootfs}/boot"

mkdir -p ${BUILD_ENV}

# Create image file
image="${SCRIPT_DIR}/spreadpi_${VERSION}.img"
echo "Initializing image file $image"
dd if=/dev/zero of=${image} bs=1MB count=$IMAGESIZE &>> $LOG
lodevice=`losetup -f --show ${image}` &>> $LOG

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
" | fdisk ${lodevice} &>> $LOG


# Set up loopback devices
dmsetup remove_all
losetup -d ${lodevice} &>> $LOG
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
chmod 755 usr/bin/qemu-arm-static

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
    DELIVERY_DIR=/usr/src/delivery LANG=C chroot ${rootfs} /$script &>> $LOG
done

# Coreutils only works with uid and guid on non-native chroot guest architecture
# LANG=C chroot --userspec=1000:1000 ${rootfs} /usr/src/delivery/files/install_spreads.sh &>> $LOG

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

# Kill remaining qemu-arm-static processes
pkill -9 -f ".*qemu-arm-static.*"


# Synchronize file systems
sync
sleep 15

# Make sure we're not in the mounted filesystem anymore, or unmount -l would silently keep waiting!
cd

# Unmount
umount -l ${bootp} &>> $LOG
umount -l ${rootfs}/usr/src/delivery &>> $LOG
umount -l ${rootfs}/dev/pts &>> $LOG
umount -l ${rootfs}/dev &>> $LOG
umount -l ${rootfs}/sys &>> $LOG
umount -l ${rootfs}/proc &>> $LOG
umount -l ${rootfs} &>> $LOG
umount -l ${rootp} &>> $LOG

# Remove build directory
rm -rf $BUILD_ENV

echo "Finishing ${image}"

# Remove partition mappings
sleep 30
kpartx -vd ${lodevice} &>> $LOG
losetup -d ${lodevice} &>> $LOG

echo "Created image ${image}"
