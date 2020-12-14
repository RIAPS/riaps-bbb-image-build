#!/usr/bin/env bash
set -e


user_func() {
    getent group gpio || sudo groupadd gpio
    getent group dialout || sudo groupadd dialout
    getent group pwm || sudo groupadd pwm

    sudo usermod -aG sudo $RIAPSUSER
    sudo usermod -aG dialout $RIAPSUSER
    sudo usermod -aG gpio  $RIAPSUSER
    sudo usermod -aG pwm $RIAPSUSER

    #MM(12/1) sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_apps
    sudo cp riaps_install_bbb.sh /home/$RIAPSUSER/
    sudo chmod 500 /home/$RIAPSUSER/riaps_install_bbb.sh
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_install_bbb.sh

    cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
    echo ">>>>> created user accounts"
}

# This function requires that riaps_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-creation/riaps_initial_keys/id_rsa.pub
# be placed on the remote node as this script is run
setup_ssh_keys() {
    # MM TODO: check which version works
    # MM TODO: sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.ssh
    # MM TODO: sudo -H -u $RIAPSUSER cat riaps_initial_keys/riaps_initial.pub >> /home/$RIAPSUSER/.ssh/authorized_keys
    # MM TODO: chmod 600 /home/$RIAPSUSER/.ssh/authorized_keys
    # MM TODO: chown -R $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh
    # MM TODO: echo ">>>>> Added unsecured public key to authorized keys for $RIAPSUSER"
    mkdir -p /home/$1/.ssh
    cat bbb_initial_keys/bbb_initial.pub >> /home/$1/.ssh/authorized_keys
    chmod 600 /home/$1/.ssh/authorized_keys
    chown -R $1:$1 /home/$1/.ssh
    echo "Added unsecured public key to authorized keys for $1"
}

# Create a file that tracks the version installed on the RIAPS node, will help in debugging efforts
create_riaps_version_file () {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.riaps
    sudo echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Ubuntu Version: $UBUNTU_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}
