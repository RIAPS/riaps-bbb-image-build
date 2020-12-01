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

    #MM(12/1) sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
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

    sudo pip3 install 'git+https://github.com/cython/cython.git@0.29.21' --verbose
    echo "installed cython"

    sudo pip3 install 'paramiko==2.6.0' 'cryptography==2.7' --verbose
    echo "installed paramiko and cryptography"
}

# Remove specific crypto package that conflict with riaps-pycom "pycryptodomex" package installation
crypto_remove() {
    sudo apt remove python3-crypto -y
    echo "removed python3-crypto"
}

pybind11_install() {
    sudo pip3 install 'pybind11==2.2.4'
    echo "install pybind11"
}

spdlog_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/spdlog-python.git $TMP/spdlog-python
    cd $TMP/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed spdlog"
}

apparmor_monkeys_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/apparmor_monkeys.git $TMP/apparmor_monkeys
    cd $TMP/apparmor_monkeys
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed apparmor_monkeys"
}

pycom_pip_pkgs() {
    sudo pip3 install 'Adafruit_BBIO == 1.2.0'
    sudo pip3 install 'pydevd==1.8.0' 'rpyc==4.1.0' 'redis==2.10.6' 'hiredis == 0.2.0' 'netifaces==0.10.7' 'paramiko==2.6.0' 'cryptography==2.7' 'cgroups==0.1.0' 'cgroupspy==0.1.6' 'psutil==5.4.2' 'butter==0.12.6' 'lmdb==0.94' 'fabric3==1.14.post1' 'pyroute2==0.5.2' 'minimalmodbus==0.7' 'pyserial==3.4' 'pybind11==2.2.4' 'toml==0.10.0' 'pycryptodomex==3.7.3' --verbose
    sudo pip3 install --ignore-installed 'PyYAML==5.1.1'
    echo "installed pip packages used by riaps-pycom"
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
    echo "setup splash screen"
}

# This function requires that bbb_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/bbb_initial_keys/id_rsa.pub
# be placed on the bbb as this script is run
setup_ssh_keys() {
    mkdir -p /home/$1/.ssh
    cat bbb_initial_keys/bbb_initial.pub >> /home/$1/.ssh/authorized_keys
    chmod 600 /home/$1/.ssh/authorized_keys
    chown -R $1:$1 /home/$1/.ssh
    echo "Added unsecured public key to authorized keys for $1"
}

setup_riaps_repo() {
    # Add RIAPS repository
    echo "get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo "add repo to sources"
    sudo add-apt-repository "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main"
    echo "riaps aptrepo setup"
}

install_riaps() {
    sudo apt-get install riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y
    echo "installed RIAPS platform"
}

pyzmq_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/pyzmq.git $TMP/pyzmq
    cd $TMP/pyzmq
    git checkout v17.1.2
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed pyzmq"
}

#install bindings for czmq. Must be run after pyzmq, czmq install.
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq_pybindings
    cd $TMP/czmq_pybindings/bindings/python
    git checkout 9ee60b18e8bd8ed4adca7fdaff3e700741da706e
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed CZMQ pybindings"
}

#install bindings for zyre. Must be run after zyre, pyzmq install.
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre_pybindings
    cd $TMP/zyre_pybindings/bindings/python
    git checkout b36470e70771a329583f9cf73598898b8ee05d14
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed Zyre pybindings"
}

#link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3'
    echo "linked pycapnp with capnproto"
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD
    mkdir -p /tmp/3rdparty/build
    cp CMakeLists.txt /tmp/3rdparty/.
    cd /tmp/3rdparty/build
    cmake ..
    make
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/
    echo "cmake install complete"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libpcap-dev libreadline-dev libsystemd-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
}


# Start of script actions
check_os_version
user_func
freqgov_off
python_install
crypto_remove
pybind11_install
spdlog_install
apparmor_monkeys_install
pycom_pip_pkgs
watchdog_timers
setup_splash
setup_ssh_keys $RIAPSAPPDEVELOPER
setup_riaps_repo
externals_cmake_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
pycapnp_install
remove_pkgs_used_to_build
#install_riaps

# Delete all of the install files from the image
sudo rm -rf /opt/riaps-install
