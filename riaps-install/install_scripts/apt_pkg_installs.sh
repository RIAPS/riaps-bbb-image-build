#!/usr/bin/env bash
set -e

# Set apt sources list grab the released packages with draft APIs
zmq_draft_apt_install() {
    echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/xUbuntu_22.04/ ./" >> /etc/apt/sources.list.d/zeromq.list
    wget https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/xUbuntu_22.04/Release.key -O- | sudo apt-key add
    sudo apt-get update
    sudo apt-get install libzmq3-dev
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-dev libcap-dev libffi-dev libgnutls28-dev libncurses5-dev libncurses-dev -y
    sudo apt-get remove libsystemd-dev libmsgpack-dev libpcap-dev -y
    sudo apt-get remove uuid-dev liblz4-dev -y
    sudo apt-get remove nettle-dev libcurl4-gnutls-dev libasio-dev -y
    sudo apt-get remove libargon2-0-dev libhttp-parser-dev libjsoncpp-dev -y
    sudo apt autoremove -y
    sudo pip3 uninstall cython -y
    echo ">>>>> removed packages used in building process that are no longer needed"
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

