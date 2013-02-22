#!/bin/sh

# THIS SCRIPT SHOULD BE EXECUTED MANUALLY BY root RIGHT AFTER DEBIAN INSTALLATION
# This script prepares virtual box for packaging into vagrant box

# break on first error
set -e
# show all executing commands
set -x

# Add admin group and add vagrant user to this group
groupadd admin && usermod -a -G admin vagrant

# install sudo
apt-get -y --no-install-recommends install sudo

# Retain SSH_AUTH_SOCK to use sudo with ssh agend
# and avoid to remember sudo password for some time
# by adding the following line to /etc/sudoers :
# Defaults	env_keep	+= "SSH_AUTH_SOCK",timestamp_timeout=0
sed -n 'H;${x;s/Defaults\senv_reset\n/&Defaults\tenv_keep\t+= "SSH_AUTH_SOCK",timestamp_timeout=0\n/;p;}' /etc/sudoers > /etc/sudoers.tmp && cp /etc/sudoers.tmp /etc/sudoers && rm /etc/sudoers.tmp

# Disable password request for users in admin group
# by adding the following line to /etc/sudoers :
# %admin	ALL=NOPASSWD: ALL
sed -n 'H;${x;s/root\sALL=(ALL)\sALL\n/&%admin\tALL=NOPASSWD: ALL\n/;p;}' /etc/sudoers > /etc/sudoers.tmp && cp /etc/sudoers.tmp /etc/sudoers && rm /etc/sudoers.tmp

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
sed -n 'H;${x;s/TCPKeepAlive\s(yes|no)?\n/&UseDNS no\n/;p;}' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp && cp /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config && rm /etc/ssh/sshd_config.tmp

# update all packages and clean up cache
apt-get -y update && apt-get -y upgrade && apt-get -y autoremove && apt-get -y clean

# blacklist pcspkr to avoid error msg on startup
echo '# Disable pcspkr error msg on startup' >> /etc/modprobe.d/blacklist.conf
echo 'blacklist pcspkr' >> /etc/modprobe.d/blacklist.conf

# Clear bash history for root user
history -d $((HISTCMD-1)) && \
rm /root/.bash_history