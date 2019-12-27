#!/bin/sh

##################################################
# Ubuntu 18.04.1 LTS (Bionic Beaver)             #
# iso: ubuntu-18.04.1-live-server-amd64.iso      #
##################################################

##################################################
# /TR 2018-10-03
##################################################

add-apt-repository universe
add-apt-repository multiverse
apt update -y
apt upgrade -y

apt install -y ssmtp bsd-mailx
apt install -y pacapt dos2unix htop mc bash-completion \
  virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 \
  fluxbox xinit chromium-browser rxvt-unicode

mkdir -p /root/tmp
cd /root/tmp || exit
git clone --depth=1 https://github.com/OpenDigitalSignage/ClientFiles
SRC="/root/tmp/ClientFiles"

# copy dsbd script and one service example file
cd $SRC/distrib/Ubuntu-18.04-LTS || exit

# create chromium service
mkdir -p /etc/dsbd.d
cp etc-dsbd.d/dsbd-browser.service /etc/dsbd.d

# create as much services as you have TV groups
systemctl link /etc/dsbd.d/dsbd-sample.service
systemctl enable dsbd-sample
systemctl restart dsbd-sample
