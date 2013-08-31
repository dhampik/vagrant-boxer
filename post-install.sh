#!/bin/sh

# THIS SCRIPT SHOULD BE EXECUTED MANUALLY BY root DIRECTLY AFTER DEBIAN INSTALLATION
# This script prepares virtual box for packaging into vagrant box
# It would be probably safe to run this script twice, because it checks existing settings

# break on first error
set -e
# show all executing commands
#set -x

# update all packages
apt-get -y update && apt-get -y upgrade

# Check if admin group already assigned to vagrant user
if ! grep -qP '^admin:[^:]*:\d*:.*vagrant' /etc/group
then
    # Add admin group and add vagrant user to this group
    groupadd admin && usermod -a -G admin vagrant
else
    echo -e '\e[01;31mNote\e[00m: vagrant user is already in the admin group'
fi

# install sudo
apt-get -y --no-install-recommends install sudo

# install openssh-server (in case someone missed that)
if [ ! -f /etc/ssh/sshd_config ];
then
    apt-get -y --no-install-recommends install openssh-server
fi

if ! grep -qP '^Defaults\tenv_keep\t\+= "SSH_AUTH_SOCK",timestamp_timeout=0' /etc/sudoers
then
    # Retain SSH_AUTH_SOCK to use sudo with ssh agend
    # and avoid to remember sudo password for some time
    # by adding the following line to /etc/sudoers :
    # Defaults	env_keep	+= "SSH_AUTH_SOCK",timestamp_timeout=0
    # !Note, that quantifiers should be escaped in sed, the contrary to PCRE
    cp /etc/sudoers /etc/sudoers.orig
    sed -i -e 's/Defaults\s\+env_reset/&\nDefaults\tenv_keep\t+= "SSH_AUTH_SOCK",timestamp_timeout=0/' /etc/sudoers
else
    echo -e '\e[01;31mNote\e[00m: Defaults\tenv_keep\t+= "SSH_AUTH_SOCK",timestamp_timeout=0 is already in /etc/sudoers'
fi

if ! grep -qP '^%admin\tALL=NOPASSWD: ALL' /etc/sudoers
then
    # Disable password request for users in admin group
    # by adding the following line to /etc/sudoers :
    # %admin	ALL=NOPASSWD: ALL
    # !Note, that quantifiers should be escaped in sed, the contrary to PCRE
    sed -i -e 's/root\s\+ALL=(ALL)\s\+ALL/&\n%admin\tALL=NOPASSWD: ALL/' /etc/sudoers
else
    echo -e '\e[01;31mNote\e[00m: "%admin\tALL=NOPASSWD: ALL" is already in /etc/sudoers'
fi

/etc/init.d/sudo restart

# Set up insecure public ssh key for vagrant user
# (it'll be automatically used by vagrant)
PUBKEY=$(wget -qO- https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub)
mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
# Check if key is already authorized
if ! fgrep -q "$PUBKEY" /home/vagrant/.ssh/authorized_keys
then
    echo "$PUBKEY" >> /home/vagrant/.ssh/authorized_keys
else
    echo -e '\e[01;31mNote\e[00m: vagrant public key already authorized'
fi

chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh/
chmod 600 /home/vagrant/.ssh/authorized_keys

if ! grep -qP '^UseDNS no' /etc/ssh/sshd_config
then
    # Disable DNS lookup and speed up connection
    # by adding the following line to /etc/ssh/sshd_config :
    # UseDNS no
    # !Note, that quantifiers should be escaped in sed, the contrary to PCRE
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
    sed -i -e 's/TCPKeepAlive\s\+yes/&\nUseDNS no/' /etc/ssh/sshd_config
else
    echo -e '\e[01;31mNote\e[00m: "UseDNS no" is already in /etc/ssh/sshd_config'
fi

/etc/init.d/ssh restart

# VirtualBox Guest Additions are already installed on Debian
# You can install the latest version manually following instructions
# at http://www.virtualbox.org/manual/ch04.html
#
#    sudo apt-get purge virtualbox*
#    sudo apt-get autoremove
#    sudo apt-get install linux-headers-$(uname -r) build-essential
#  Make sure to insert the guest additions image by using the GUI and clicking on “Devices” followed by “Install Guest Additions.”. Then run the following to mount the CD Rom:
#    sudo mount /dev/cdrom /media/cdrom
#  Run the shell script which matches your system. For linux on x86, it is the following:
#    sudo sh /media/cdrom/VBoxLinuxAdditions.run
#    sudo shutdown -r now

# remove not needed packages and clean aptitude cache
apt-get -y autoremove && apt-get -y clean

if ! grep -qP '^blacklist pcspkr' /etc/modprobe.d/blacklist.conf
then
    # blacklist pcspkr to avoid error msg on startup
    cp /etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf.orig
    cat << EOF >> /etc/modprobe.d/blacklist.conf
# Disable pcspkr error msg on startup
blacklist pcspkr
EOF
else
    echo -e '\e[01;31mNote\e[00m: "blacklist pcspkr" is already in /etc/modprobe.d/blacklist.conf'
fi

if ! grep -qP '^GRUB_TIMEOUT=0' /etc/default/grub
then
    # Remove 5s grub timeout to speed up booting
    cp /etc/default/grub /etc/default/grub.orig
    sed -i -e 's/GRUB_TIMEOUT=\([0-9]\)\+/GRUB_TIMEOUT=0/' /etc/default/grub
    update-grub
else
    echo -e '\e[01;31mNote\e[00m: GRUB_TIMEOUT already set to 0 in /etc/default/grub'
fi

# clear history
history -c

echo -e '\e[01;31mPlease reboot now\e[00m'