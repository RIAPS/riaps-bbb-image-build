#!/usr/bin/env bash
set -e

# Setting up for use with Ubuntu netplan methodology
setup_network() {
    echo ">>>>> setup dhcp client configuration"
    touch /etc/systemd/network/dhcp.network
    cp etc/systemd/network/dhcp.network /etc/systemd/network/dhcp.network
}
