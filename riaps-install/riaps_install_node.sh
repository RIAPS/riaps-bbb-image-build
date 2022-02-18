#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# Add RIAPS repository
echo ">>>>> get riaps public key"
sudo update-ca-certificates -f
wget https://riaps.isis.vanderbilt.edu/keys/riapspublic.key
sudo apt-key add riapspublic.key
echo ">>>>> add repo to sources"
sudo add-apt-repository "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main"
rm riapspublic.key
echo ">>>>> riaps aptrepo setup"

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-pycom-armhf riaps-timesync-armhf -y
echo "installed RIAPS platform"
