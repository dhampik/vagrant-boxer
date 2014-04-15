vagrant-boxer
=============

This project devoted to simplified process of custom vagrant box configuration.

**Update:** it's probably better to use [veewee](https://github.com/jedi4ever/veewee). I didn't know about it when I made this project. Leaving the repo just in case.

Guest system installation
-------------------------

I prefer to use [Debian](http://debian.org/ "Visit Debian website") for servers, so this guide would be about Debian only (I think you might find something useful for other operating systems too).

First, you need to install [VirtualBox](https://www.virtualbox.org/ "Visit virtualbox website") to make things happen.

Then you need to download debian installer iso, e.g [debian-squeeze-i386-6.0.7-netinst](http://cdimage.debian.org/debian-cd/6.0.7/i386/iso-cd/debian-6.0.7-i386-netinst.iso "Download netinst debian iso") which was used here.

###The following settings were used:###
- RAM size 384 MB
- VDI disk image
- Dynamic size: 40 GB
- *Settings &rarr; System &rarr; Motherboard &rarr; Boot order &rarr; Diskette* was disabled
- *Settings &rarr; Audio* was disabled
- *Settings &rarr; Network* was set to *NAT*

###Installation process settings are default:###
- Language: English
- Location: United States
- Keyboard layout: American English
- Hostname: vagrant
- Domain name: empty
- Root password: vagrant
- Main account login: vagrant
- Main account password: vagrant
- Timezone: Eastern
- Partitioning method: Guided &rarr; use entire disk
- All files on the same partition
- Swap partition size: 768 MB
- Debian archive mirror country: United States
- Debian archive mirror: ftp.us.debian.org
- No proxy
- No popularity-contest
- Additional packages: ssh server, standard system utilities
- GRUB installed to MBR

You can create your own Virtual Machine with custom settings based on the above settings.

###Basic configuration before creating vagrant box:###

To prepare virtual machine for packaging you should login as `root` and run `post-install.sh` which you can find in this repository.
You can do it by executing the following command:
```bash
wget -O- https://raw.github.com/dhampik/vagrant-boxer/master/post-install.sh | bash
```

Read comments in [post-install.sh](https://github.com/dhampik/vagrant-boxer/blob/master/post-install.sh "View post-install.sh source code") to figure out how does it work.

###We can now package virtual machine into vagrant box:###
```bash
# Create dir anyware to store vagrant box, name doesn't matter
mkdir vagrant
cd vagrant
# "vagrant-box-debian-6.0.6-i386" is the name of virtual machine listed in virtualbox manager
vagrant package --base vagrant-box-debian-6.0.6-i386 --output base-debian-squeeze-i386.box
```

###You can now run your own vagrant box:###
```bash
# change dir to the one where you saved your packaged vagrant box
cd vagrant
# Add vagrant box to the list of your boxes and name it "dev-box"
vagrant box add dev-box base-debian-squeeze-i386.box
# Create dir for you vagrant project and change current dir to it
mkdir dev-env
cd dev-env
# Init vagrant box
vagrant init dev-box
# Run vagrang box
vagrant up
```

Now you have your vagrant box up and running. You can access it via ssh.
If you are using Windows, you should do the following to access vagrant box via [PuTTy](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html "Go to PuTTy download page"):
- [install PuTTy](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html "Go to PuTTy download page")
- convert the %HOMEPATH%\\.vagrant.d\insecure_private_key to .ppk using PuTTYGen (Run puttygen, load key, save private key)
- use the above converted .ppk key for your PuTTY session (This could be configured through *Connection &rarr; SSH &rarr; Auth &rarr; Private key file* option when you create a new session)

###Here you should use different provision scripts and cookbooks to setup all required software###
