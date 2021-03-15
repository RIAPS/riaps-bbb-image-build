#!/usr/bin/env bash
set -e


user_func() {
    sudo usermod -aG sudo $rfs_username
    sudo usermod -aG dialout $rfs_username
    sudo usermod -aG gpio  $rfs_username
    sudo usermod -aG pwm $rfs_username

    cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
    echo ">>>>> created user accounts"
}

riaps_dir_setup() {
    sudo -H -u $rfs_username mkdir -p /home/$rfs_username/riaps_apps
    sudo cp riaps_install_bbb.sh /home/$rfs_username/
    sudo chmod 500 /home/$rfs_username/riaps_install_bbb.sh
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/riaps_install_bbb.sh

    echo ">>>>> setup riaps folder and install script"
}

# This function requires that riaps_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-creation/riaps_initial_keys/id_rsa.pub
# be placed on the remote node as this script is run
setup_ssh_keys() {
    sudo -H -u $rfs_username mkdir -p /home/$rfs_username/.ssh
    sudo -H -u $rfs_username cat riaps_initial_keys/riaps_initial.pub >> /home/$rfs_username/.ssh/authorized_keys
    chmod 600 /home/$rfs_username/.ssh/authorized_keys
    chown -R $rfs_username:$rfs_username /home/$rfs_username/.ssh
    echo ">>>>> Added unsecured public key to authorized keys for $rfs_username"
}

# Create a file that tracks the version installed on the RIAPS node, will help in debugging efforts
create_riaps_version_file () {
    sudo -H -u $rfs_username mkdir -p /home/$rfs_username/.riaps
    sudo echo "RIAPS Version: $rfs_username" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo echo "Ubuntu Version: $release" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $rfs_username" >> /home/$rfs_username/.riaps/riapsversion.txt
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/.riaps/riapsversion.txt
    sudo -H -u $rfs_username chmod 600 /home/$rfs_username/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}
