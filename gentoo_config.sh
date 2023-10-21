Configuración de particiones para BIOS
# Particion del Grub
/dev/sdb1   /boot    xfs     1 GiB      BIOS boot partition

# Particion del Swap
/dev/sdb2   is not mounted      swap     10 GiB     Swap partition

# Particion del root
/dev/sdb3   /       xfs     100 GiB - remainder     Root partition




lsblk       # Show partition
fdisk /dev/sdb         # crear particionaes
o # creating a new disklabel
d # removing all partitions
n # creating the boot partition
    p - primary
    1 - partition number
    +1G

n # creating the swap partition
    p - primary
    2 - partition number
    +10G
t # set partition type
    2 - partition number
    82 - hex code for swap

n # creating the root partition
    p - primary
    3 - partition number
    remainder

w # saving the partition layout


# XFS partitions
mkfs.xfs /dev/sdb1 # boot partition
mkfs.xfs /dev/sdb3 # root partition

# Swap partition
mkswap /dev/sdb2 # initialize the swap partitions
swapon /dev/sdb2 # activate the swap partitions



# Mounting the root partition
mkdir --parents /mnt/gentoo
mount /dev/sdb3 /mnt/gentoo



# Setting the date and time
date
date 102013302023 # month|day|hour|minute|year



# Downloading the stage tarball
cd /mnt/gentoo
links https://gentoo.org/downloads/
    # download "Stage 3 openrc 2023-06-04 239 MiB"


# Unpacking the stage tarball
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner


# Configuring compile options
nano -w /mnt/gentoo/etc/portage/make.conf
    
    COMMON_FLAGS="-march=native -O2 -pipe" # Configuring the architecture
                                           # -pipe uses more memory
    FEATURES="candy parallel-fetch parallel-install"
    MAKEOPTS="-j8 -l8"



# Gentoo ebuild repository
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cat /mnt/gentoo/etc/portage/repos.conf/gentoo.conf


# Copy DNS info
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/


# Mounting the necessary filesystems
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run


# Entering the new environment
chroot /mnt/gentoo /bin/bash
source /etc/profile

# Preparing for a bootloader
mount /dev/sda1 /boot

# Configuring Portage
# Installing a Gentoo ebuild repository snapshot from the web
emerge-webrsync

# Optional: Updating the Gentoo ebuild repository
emerge --sync

# Reading news items
eselect news list
eselect news read


# Choosing the right profile
eselect profile list
eselect profile set 2 # select the same version
eselect profile list


# Updating the @world set
emerge --ask --verbose --update --deep --newuse @world
emerge --depclean



# Configuring compile options
nano -w /etc/portage/make.conf
    
    USE="-gnome -kde alsa pulseaudio"


# CPU_FLAGS_*
emerge -av cpuid2cpuflags
cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags


# Configuring compile options
nano -w /etc/portage/make.conf
    
    ACCEPT_LICENSE="*"



# Timezone
ls /usr/share/zoneinfo/America/Guatemala
echo "America/Guatemala" > /etc/timezone
emerge --config sys-libs/timezone-data



# Configure locales
# Locale generation
nano -w /etc/locale.gen

    es_MX * # uncommentd the es locale

locale-gen
eselect locale list
eselect locale set 9
env-update && source /etc/profile

emerge -av sys-kernel/linux-firmware

# Installing a distribution kernel
emerge -av sys-kernel/gentoo-kernel-bin


# Installing the kernel sources
eselect kernel list
ls -l /usr/src/linux

# Creating the fstab file
nano -w /etc/fstab

    /dev/sdb1   /boot        xfs    defaults    0 2
    /dev/sdb2   none         swap   sw                   0 0
    /dev/sdb3   /            xfs    defaults,noatime              0 1

    /dev/cdrom  /mnt/cdrom   auto    noauto,user          0 0




# Hostname
echo tux > /etc/hostname

# Network
# DHCP via dhcpcd (any init system)
emerge -av net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start
emerge -av --noreplace net-misc/netifrc
ifconfig
nano /etc/conf.d/net
    config_{controldor_eth0}="dhcp"


cd /etc/init.d
ln -s net.lo net.{controldor_eth0}
rc-update add net.{controldor_eth0} default





# The hosts file
nano -w /etc/hosts
    127.0.0.1     tux.homenetwork tux localhost


# System information
# Root password
passwd


# Init and boot configuration
# OpenRC
nano /etc/conf.d/hwclock
    clock="local"


# System logger
# OpenRC
emerge -av app-admin/sysklogd
rc-update add sysklogd default

# Optional: File indexing
emerge -av sys-apps/mlocate
updatedb
locate # for verified if the command exits


# Time synchronization
emerge -av net-misc/chrony
rc-update add chronyd default


# Filesystem tools
emerge -av sys-fs/e2fsprogs
emerge -av sys-fs/dosfstools



# Networking tools
emerge -av wireless-tools # optional



# Default: GRUB

# echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf # for efi users
emerge -av sys-boot/grub
# emerge -av sys-boot/os-prober

grub-install /dev/sdb1


# Rebooting the system
root: exit
livecd~# cd
livecd~# umount -l /mnt/gentoo/dev{/shm,/pts,}
livecd~# umount -R /mnt/gentoo
livecd~# reboot



# User administration
# Adding a user for daily use
useradd -m -G users,wheel,audio,video -s /bin/bash larry
passwd larry


# Disk cleanup
# Removing tarballs
rm /stage3-*.tar.*



Order:
    COMMON_FLAGS
    ...FLAGS

    USE

    ACCEPT_LICENSE

    FEATURES
    MAKEOPTS

    ...EXTRAS















