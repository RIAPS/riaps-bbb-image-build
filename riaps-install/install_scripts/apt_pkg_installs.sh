#!/usr/bin/env bash
set -e


#install opendht prerequisites - expect libreadline-dev libncurses-dev libmsgpack-dev libgnutls28-dev libasio-dev installed
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
    sudo apt-get remove libboost-all-dev libcap-dev libffi-dev libgnutls28-dev libncurses5-dev libncurses-dev -y
    sudo apt-get remove libsystemd-dev -y
    sudo apt-get remove nettle-dev libcurl4-gnutls-dev libasio-dev -y
    sudo apt-get remove libargon2-0-dev libfmt-dev libhttp-parser-dev libjsoncpp-dev -y
    sudo apt autoremove -y
    echo ">>>>> removed packages used in building process, no longer needed"
}

# Setup RIAPS repository
riaps_prereq() {
    sudo update-ca-certificates -f
    # Add RIAPS repository
    echo ">>>>> get riaps public key"
    sudo rdate -n -4 time.nist.gov
    wget https://riaps.isis.vanderbilt.edu/keys/riapspublic.key --no-check-certificate
    sudo apt-key add riapspublic.key
    echo ">>>>> add repo to sources"
    sudo add-apt-repository "deb [arch=${deb_arch}] https://riaps.isis.vanderbilt.edu/aptrepo/ $deb_codename main"
    rm riapspublic.key
    echo ">>>>> riaps aptrepo setup"
}

rust_install() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y
}
