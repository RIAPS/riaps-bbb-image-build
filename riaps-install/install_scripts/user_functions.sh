#!/usr/bin/env bash
set -e


# Added changes for SPI, but leaving it off for now for the BBB (work mainly done on RPi at this time - 08/31/2021)
user_func() {
    sudo usermod -aG sudo $rfs_username
    sudo usermod -aG dialout $rfs_username
    sudo usermod -aG gpio  $rfs_username
    sudo usermod -aG pwm $rfs_username
    sudo usermod -aG spi $rfs_username

    # This can not be done at this point (files not available, probably need a reboot first)
    #sudo chown :spi /dev/spidev0.0
    #sudo chmod g+rw /dev/spidev0.0
    #sudo chown :spi /dev/spidev0.1
    #sudo chmod g+rw /dev/spidev0.1

    cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
    echo ">>>>> created user accounts"
}

# package install changed 06/23, utilize riaps_fab to install riaps packages
riaps_dir_setup() {
    sudo mkdir -p /home/$rfs_username/riaps_apps
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/riaps_apps
    #sudo cp riaps_install_node.sh /home/$rfs_username/
    #sudo chmod 500 /home/$rfs_username/riaps_install_node.sh
    #sudo chown $rfs_username:$rfs_username /home/$rfs_username/riaps_install_node.sh
    sudo mkdir -p /home/$rfs_username/.ssh
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/.ssh
    echo ">>>>> setup riaps folder and install script"
}

# This function requires that riaps_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-creation/riaps_initial_keys/id_rsa.pub
# be placed on the remote node as this script is run
setup_ssh_keys() {
    sudo mkdir -p /home/$rfs_username/.ssh
    sudo cat riaps_initial_keys/riaps_initial.pub >> /home/$rfs_username/.ssh/authorized_keys
    chmod 600 /home/$rfs_username/.ssh/authorized_keys
    sudo chown -R $rfs_username:$rfs_username /home/$rfs_username/.ssh
    echo ">>>>> Added unsecured public key to authorized keys for $rfs_username"
}

# Create a file that tracks the version installed on the RIAPS node, will help in debugging efforts
create_riaps_version_file () {
    sudo mkdir -p /home/$rfs_username/.riaps
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/.riaps
    sudo echo "RIAPS Version: $rfs_username" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo echo "$deb_codename Version: $release" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $rfs_username" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/.riaps/riapsversion.txt
    sudo chmod 600 /home/$rfs_username/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}
