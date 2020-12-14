#!/usr/bin/env bash
set -e


# net-tools is already installed on some architectures.  It is installed here to make sure it is available.
setup_network() {
    echo ">>>>> replacing resolv.conf"
    touch /etc/resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.preriaps
    cp  etc/resolv-riaps.conf /etc/resolv.conf
    echo ">>>>> replaced resolv.conf"
}
