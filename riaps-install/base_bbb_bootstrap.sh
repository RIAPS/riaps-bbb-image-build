#!/usr/bin/env bash
set -e

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, GIT, pkg-config, python3-dev, python3-setuptools
# pps-tools, libpcap0.8, nettle6, libgnutls30, libncurses5

# Differences from riaps-integration/riaps-node-creation/base-bbb-bootstrap.#!/bin/sh
# This method uses riaps-bionic.conf to setup all username and all apt packages desired, so they are not in the
# install_scripts for this repo.  The omap-image-builder.patch handles the network_setup.sh script information and
# the quota setup.
# MM TODO - check this is how it happens: base file copies (i.e. /usr/bin/set-unique_hostname and /etc/sudoers.d/riaps) like DEBIAN package setup

#contains: rfs_username, release_date
if [ -f /etc/rcn-ee.conf ] ; then
	. /etc/rcn-ee.conf
fi
if [ -f /etc/oib.project ] ; then
	. /etc/oib.project
fi

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done
    echo ">>>>> sourced install scripts"
}

pycom_pip_pkgs_bbb() {
    sudo pip3 install 'Adafruit_BBIO == 1.2.0'
    echo ">>>>> installed pip packages specifically for BBB"
}

setup_splash() {
    echo "################################################################################" > motd
    echo "# Acknowledgment:  The information, data or work presented herein was funded   #" >> motd
    echo "# in part by the Advanced Research Projects Agency - Energy (ARPA-E), U.S.     #" >> motd
    echo "# Department of Energy, under Award Number DE-AR0000666. The views and         #" >> motd
    echo "# opinions of the authors expressed herein do not necessarily state or reflect #" >> motd
    echo "# those of the United States Government or any agency thereof.                 #" >> motd
    echo "################################################################################" >> motd
    sudo mv motd /etc/motd
    echo ">>>>> setup motd screen"
    # Enable issue.net, which is autopopulated by omap-image-builder
    sed -i '/Banner/d' /etc/ssh/sshd_config # Remove default banner configuration
    echo " " >> /etc/ssh/sshd_config
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config # Enable banner
    echo ">>>>> setup splash screen"
}

install_riaps() {
    sudo apt-get install riaps-pycom riaps-timesync-$deb_arch -y
    echo ">>>>> installed RIAPS platform"
}


# Start of script actions
source_scripts
RIAPS_PREFIX="/opt/riaps" # for location of compiled zmq libraries
setup_peripherals
user_func
riaps_dir_setup
# setup_ssh_keys - removed, must put dev vm keys on bbb during initial setup
freqgov_off
watchdog_timers
setup_splash
setup_hostname
cython_install
build_external_libraries
python_install
pycapnp_install
apparmor_monkeys_install
spdlog_python_install
py_lmdb_install
pip3_3rd_party_installs
pycom_pip_pkgs_bbb
prctl_install
# move zmq python installs to last due to cython being updated to 3.0.2 for the pyzmq build
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
remove_pkgs_used_to_build
#riaps_prereq - DEV: currently working with a non-apt release, no repo to add yet
create_riaps_version_file
set_date

# Current method is to create the base RIAPS image without the RIAPS packages
#install_riaps

# Delete all of the install files from the image
sudo rm -rf /opt/riaps-install
