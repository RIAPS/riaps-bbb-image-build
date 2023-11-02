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

# Ubuntu 22.04 now sets the user directory permissions to 750, need 755 for riaps apps to load
riaps_dir_setup() {
    sudo mkdir -p /home/$rfs_username/riaps_apps
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/riaps_apps
    sudo mkdir -p /home/$rfs_username/.ssh
    sudo chown $rfs_username:$rfs_username /home/$rfs_username/.ssh
    sudo chmod 755 /home/$rfs_username
    echo ">>>>> setup riaps folder and install script"
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
