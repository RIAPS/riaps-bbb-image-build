#!/usr/bin/env bash
set -e


#install opendht prerequisites - expect libncurses5-dev installed
opendht_prereqs_install() {
    # run liblinks script to link gnutls and msgppack
    chmod +x /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    PREVIOUS_PWD=$PWD
    cd /usr/lib/${ARCHINSTALL}
    sudo /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    cd $PREVIOUS_PWD
    echo ">>>>> installed opendht prerequisites"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libcap-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libpcap-dev libreadline-dev libsystemd-dev libssl-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
    echo ">>>>> removed packages used in building process, no longer needed"
}

# Setup RIAPS repository
riaps_prereq() {
    # Add RIAPS repository
    echo ">>>>> get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo ">>>>> add repo to sources"
    sudo add-apt-repository -r "deb [arch=${NODE_ARCH}] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" || true
    sudo add-apt-repository -n "deb [arch=${NODE_ARCH}] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main"
    sudo apt-get update
    echo ">>>>> riaps aptrepo setup"
}
