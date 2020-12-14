#!/usr/bin/env bash
set -e

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, GIT, pkg-config, python3-dev, python3-setuptools
# pps-tools, libpcap0.8, nettle6, libgnutls30, libncurses5

#contains: rfs_username, release_date
if [ -f /etc/rcn-ee.conf ] ; then
	. /etc/rcn-ee.conf
fi
if [ -f /etc/oib.project ] ; then
	. /etc/oib.project
fi

# Script Variables
RIAPSUSER=${rfs_username}

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/node_creation_bbb.conf"
    echo ">>>>> sourced install scripts"
}

pycom_pip_pkgs_bbb() {
    sudo pip3 install 'Adafruit_BBIO == 1.2.0'
    echo "installed pip packages specifically for BBB"
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
    echo "setup motd screen"
    # Enable issue.net, which is autopopulated by omap-image-builder
    sed -i '/Banner/d' /etc/ssh/sshd_config # Remove default banner configuration
    echo " " >> /etc/ssh/sshd_config
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config # Enable banner
    echo "setup splash screen"
}

install_riaps() {
    sudo apt-get install riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y
    echo "installed RIAPS platform"
}


# Start of script actions
source_scripts
# MM TODO: check_os_version
user_func
freqgov_off
# MM TODO: opendht_prereqs_install
# MM TODO: setup_hostname???
setup_network
python_install
cython_install
# Not needed for 20.04 - crypto_remove
pybind11_install
spdlog_install
apparmor_monkeys_install
pip3_3rd_party_installs
pycom_pip_pkgs_bbb
# MM TODO: could not install, try manually - butter_install
# MM TODO: prctl_install
watchdog_timers
setup_splash
setup_ssh_keys
# MM TODO:  need to setup focal apt repo first - riaps_prereq
# MM TODO: externals_cmake_install
# MM TODO: pyzmq_install
# MM TODO: czmq_pybindings_install
# MM TODO: zyre_pybindings_install
# MM TODO: pycapnp_install
# MM TODO: remove_pkgs_used_to_build
# MM TODO: create_riaps_version_file
#install_riaps

# Delete all of the install files from the image
sudo rm -rf /opt/riaps-install
