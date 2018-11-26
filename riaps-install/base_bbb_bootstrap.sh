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
RIAPSAPPDEVELOPER=${rfs_username}

# Script functions
check_os_version() {
    # Need to write code here to check OS version and architecture.
    # The installation should fail if the OS version is not correct.
    true
}

user_func() {
    getent group gpio || sudo groupadd gpio
    getent group dialout || sudo groupadd dialout
    getent group pwm || sudo groupadd pwm

    sudo usermod -aG sudo $RIAPSAPPDEVELOPER
    sudo usermod -aG dialout $RIAPSAPPDEVELOPER
    sudo usermod -aG gpio  $RIAPSAPPDEVELOPER
    sudo usermod -aG pwm $RIAPSAPPDEVELOPER

    sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
    sudo cp riaps_install_bbb.sh /home/$RIAPSAPPDEVELOPER/
    sudo chmod 500 /home/$RIAPSAPPDEVELOPER/riaps_install_bbb.sh
    sudo chown $RIAPSAPPDEVELOPER:$RIAPSAPPDEVELOPER /home/$RIAPSAPPDEVELOPER/riaps_install_bbb.sh

    cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
    echo "setup user account"
}

freqgov_off() {
    touch /etc/default/cpufrequtils
    echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
    sudo systemctl disable ondemand
    sudo systemctl enable cpufrequtils
    echo "setup frequency and governor"
}

# Install packages that take a long time compiling on the BBBs to minimize user RIAPS installation time
python_install() {
    sudo pip3 install --upgrade pip
    echo "upgraded pip"

    sudo pip3 install pydevd
    echo "installed pydev"

    sudo pip3 install 'git+https://github.com/cython/cython.git@0.28.5' --verbose
    echo "installed cython"

    sudo pip3 install 'paramiko==2.4.1' 'cryptography==2.1.4' --verbose
    echo "installed paramiko and cryptography"
}

watchdog_timers() {
    echo " " >> /etc/sysctl.conf
    echo "###################################################################" >> /etc/sysctl.conf
    echo "# Enable Watchdog Timer on Kernel Panic and Kernel Oops" >> /etc/sysctl.conf
    echo "# Added for RIAPS Platform (01/25/18, MM)" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
    echo "kernel.panic = 5" >> /etc/sysctl.conf
    echo "added watchdog timer values"
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
}

# This function requires that bbb_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/bbb_initial_keys/id_rsa.pub
# be placed on the bbb as this script is run
setup_ssh_keys() {
    mkdir -p /home/$1/.ssh
    cp bbb_initial_keys/bbb_initial.pub /home/$1/.ssh/bbb_initial.pub
    chown $1:$1 /home/$1/.ssh/bbb_initial.pub
    cat /home/$1/.ssh/bbb_initial.pub >> /home/$1/.ssh/authorized_keys
    chown $1:$1 /home/$1/.ssh/authorized_keys
    chmod 600 /home/$1/.ssh/authorized_keys
    echo "Added unsecured public key to authorized keys for $1"
}

setup_riaps_repo() {
    # Add RIAPS repository
    echo "get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo "add repo to sources"
    sudo add-apt-repository "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main"
    echo "riaps aptrepo setup"
}

install_riaps() {
    sudo apt-get install riaps-externals-armhf riaps-core-armhf riaps-pycom-armhf riaps-systemd-armhf riaps-timesync-armhf -y
    echo "installed RIAPS platform"
}

# Start of script actions
check_os_version
user_func
freqgov_off
python_install
watchdog_timers
setup_splash
setup_ssh_keys $RIAPSAPPDEVELOPER
setup_riaps_repo
install_riaps

# Delete all of the install files from the image
sudo rm -rf /opt/riaps-install
