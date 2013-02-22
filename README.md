vagrant-boxer
=============

This is what options are used by debian installer by default

vagrant-box-debian-6.0.6-i386

debian-squeeze-i386-6.0.6-netinst iso was used
RAM size 384 MB
VDI disk image
Dynamic size 40 GB
Settings->System->Motherboard->Boot order->Diskette was disabled
Settings->Audio disabled
Settings->Network = NAT

Install
Language: English
Location: United States
Keyboard layout: American English

Hostname: vagrant
Domain name: empty
Root password: vagrant
Main account login: vagrant
Main account password: vagrant

Timezone: Eastern

Partitioning method: Guided - use entire disk
All files on the same partition
Swap partition size: 768 MB

Debian archive mirror country: United States
Debian archive mirror: ftp.us.debian.org

No proxy

No popularity-contest

Additional packages: ssh server, standard system utilities

GRUB installed to MBR

To prepare virtual machine for packaging you should login as root and run post-install.sh