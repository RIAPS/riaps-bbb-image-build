#!/usr/bin/env bash
set -e

# net-tools is already installed on some architectures.  It is installed here to make sure it is available.
setup_network() {
    echo ">>>>> setup dhcp client configuration"
    touch /etc/systemd/network/dhcp.network
    cp etc/systemd/network/dhcp.network /etc/systemd/network/dhcp.network
}
