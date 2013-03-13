#!/bin/sh

# THIS SCRIPT SHOULD BE EXECUTED MANUALLY BY root DIRECTLY AFTER DEBIAN INSTALLATION
# This script prepares virtual box for packaging into vagrant box

# break on first error
set -e
# show all executing commands
set -x

# update all packages
apt-get -y update && apt-get -y upgrade

# Add admin group and add vagrant user to this group
groupadd admin && usermod -a -G admin vagrant

# install sudo
apt-get -y --no-install-recommends install sudo

# Retain SSH_AUTH_SOCK to use sudo with ssh agend
# and avoid to remember sudo password for some time
# by adding the following line to /etc/sudoers :
# Defaults	env_keep	+= "SSH_AUTH_SOCK",timestamp_timeout=0
# !Note, that quantifiers should be escaped in sed, the contrary to PCRE
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/Defaults\s\+env_reset/&\nDefaults\tenv_keep\t+= "SSH_AUTH_SOCK",timestamp_timeout=0/' /etc/sudoers

# Disable password request for users in admin group
# by adding the following line to /etc/sudoers :
# %admin	ALL=NOPASSWD: ALL
# !Note, that quantifiers should be escaped in sed, the contrary to PCRE
sed -i -e 's/root\s\+ALL=(ALL)\s\+ALL/&\n%admin\tALL=NOPASSWD: ALL/' /etc/sudoers

/etc/init.d/sudo restart

# Set up insecure public ssh key for vagrant user
# (it'll be automatically used by vagrant)
wget -P /home/vagrant https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
cat /home/vagrant/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh/
chmod 600 /home/vagrant/.ssh/authorized_keys
rm /home/vagrant/vagrant.pub

# Disable DNS lookup and speed up connection
# by adding the following line to /etc/ssh/sshd_config :
# UseDNS no
# !Note, that quantifiers should be escaped in sed, the contrary to PCRE
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sed -i -e 's/TCPKeepAlive\s\+yes/&\nUseDNS no/' /etc/ssh/sshd_config

/etc/init.d/ssh restart

# Install latest virtualbox guest addititions
cp /etc/apt/sources.list /ect/apt/sources.list.orig
cat << EOF >> /etc/apt/sources.list

# VirtualBox Guest Additions source for automatic installation from packages
deb http://download.virtualbox.org/virtualbox/debian squeeze contrib non-free
EOF

wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -

# update all package sources
apt-get -y update

# uninstall default virtual box guest additions
apt-get -y purge virtualbox-ose-guest-dkms virtualbox-ose-guest-x11 virtualbox-ose-guest-utils

# install latest virtualbox
apt-get -y install virtualbox-4.2

# remove not needed packages and clean aptitude cache
apt-get -y autoremove && apt-get -y clean

# blacklist pcspkr to avoid error msg on startup
cp /etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf.orig
cat << EOF >> /etc/modprobe.d/blacklist.conf
# Disable pcspkr error msg on startup
blacklist pcspkr
EOF

# Remove 5s grub timeout to speed up booting
cp /etc/default/grub /etc/default/grub.orig
sed -i -e 's/GRUB_TIMEOUT=\([0-9]\)\+/GRUB_TIMEOUT=0/' /etc/default/grub

update-grub

shutdown -r now