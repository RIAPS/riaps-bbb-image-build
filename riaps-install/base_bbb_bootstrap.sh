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

# Indication of base release 20.04 to help in determining if a step in the install scripts are needed.
REL_BASE_20_04='20.04'

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
    sudo apt-get install riaps-core-$deb_arch riaps-pycom-$deb_arch riaps-timesync-$deb_arch -y
    echo ">>>>> installed RIAPS platform"
}


# Start of script actions
source_scripts
setup_peripherals
user_func
# MM TODO: riaps_dir_setup
# MM TODO: setup_ssh_keys
freqgov_off
watchdog_timers
setup_splash
setup_hostname
python_install
cython_install
opendht_prereqs_install
#externals_cmake_install
#pycapnp_install
#pyzmq_install
#czmq_pybindings_install
#zyre_pybindings_install
apparmor_monkeys_install
butter_install
rpyc_install
py_lmdb_install
pip3_3rd_party_installs
pycom_pip_pkgs_bbb
prctl_install
# MM TODO: remove_pkgs_used_to_build
# MM TODO:  need to setup focal apt repo first - riaps_prereq
# MM TODO: create_riaps_version_file

# Current method is to create the base RIAPS image without the RIAPS packages
#install_riaps

# Delete all of the install files from the image
# MM TODO: sudo rm -rf /opt/riaps-install
