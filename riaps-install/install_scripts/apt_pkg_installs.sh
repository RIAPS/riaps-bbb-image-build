#!/usr/bin/env bash
set -e


# Install security packages that take a long time compiling
# python3-crypto and python3-keyrings.alt conflict with pycryptodomex.
# These packages are not included in Ubuntu 20.04.
# Removing for Ubuntu 18.04, in case it exists in the original image.
security_pkg_install() {
    echo ">>>>> add security packages"
    sudo pip3 install 'paramiko==2.7.1' 'cryptography==2.9.2' --verbose

    if [[ "$release" == *"REL_BASE_18_04"* ]]; then
        sudo apt-get remove python3-crypto python3-keyrings.alt -y
    fi
    echo ">>>>> security packages setup"
}

#install opendht prerequisites - expect libncurses5-dev installed
opendht_prereqs_install() {
    # run liblinks script to link gnutls and msgppack
    PREVIOUS_PWD=$PWD
    chmod +x $PREVIOUS_PWD/liblinks.sh
    cd /usr/lib/arm-linux-gnueabihf
    sudo $PREVIOUS_PWD/liblinks.sh
    cd $PREVIOUS_PWD
    echo ">>>>> installed opendht prerequisites"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libpcap-dev libreadline-dev libsystemd-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
    echo ">>>>> removed packages used in building process, no longer needed"
}

# Setup RIAPS repository
riaps_prereq() {
    # Add RIAPS repository
    echo ">>>>> get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo ">>>>> add repo to sources"
    sudo add-apt-repository "deb [arch=${deb_arch}] https://riaps.isis.vanderbilt.edu/aptrepo/ $deb_codename main"
    echo ">>>>> riaps aptrepo setup"
}
