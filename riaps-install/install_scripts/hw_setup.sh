#!/usr/bin/env bash
set -e


# Script functions
check_os_version() {
    # Check that the intended host architecture is really what is setup here, if not then stop installation.
    host_architecture="$(dpkg --print-architecture)"
    echo ">>>>> Node arch: $host_architecture"
    echo ">>>>> Requested arch: $NODE_ARCH"
    if [ "$host_architecture" = "$NODE_ARCH" ]; then
        echo ">>>>> Host architecture intended for installation matches the node architecture."
    else
        echo ">>>>> Host architecture intended for installation does not matches the node architecture, please correct and start again."
        exit
    fi

    # The installation fails if the requested OS version is not the same as the node version or is not
    # in the list of available versions
    VALID_SETUP=0
    NODE_OS_VERSION="$(lsb_release -sr | cut -d ' ' -f 1)"
    echo ">>>>> Node OS: $NODE_OS_VERSION"
    echo ">>>>> Requested OS: $UBUNTU_VERSION_INSTALL"
    for version in ${UBUNTU_VERSION_OPTS[@]}; do
        if [ "$version" = "$UBUNTU_VERSION_INSTALL" ] && [ "$version" = "$NODE_OS_VERSION" ]; then
            VALID_SETUP=1
        fi
    done

    if [ $VALID_SETUP == 1 ]; then
        echo ">>>>> System setup is valid, installation will begin."
    else
        echo ">>>>> System setup is invalid, choose Ubuntu version that is available (${UBUNTU_VERSION_OPTS[*]})."
        exit
    fi
}

random_num_gen_install() {
    sudo systemctl start rng-tools.service
}

# cpufrequtils is already installed on some architectures, but is needed to set this performance.
# Therefore, it is installed here to make sure it is available.
freqgov_off() {
    touch /etc/default/cpufrequtils
    echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
    sudo systemctl disable ondemand
    sudo systemctl enable cpufrequtils
    echo ">>>>> setup frequency and governor"
}

watchdog_timers() {
    echo " " >> /etc/sysctl.conf
    echo "###################################################################" >> /etc/sysctl.conf
    echo "# Enable Watchdog Timer on Kernel Panic and Kernel Oops" >> /etc/sysctl.conf
    echo "# Added for RIAPS Platform (01/25/18, MM)" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
    echo "kernel.panic = 5" >> /etc/sysctl.conf
    echo ">>>>> added watchdog timer values"
}

setup_hostname() {
    cp usr/bin/set_unique_hostname /usr/bin/set_unique_hostname
    sudo chmod +x /usr/bin/set_unique_hostname
    echo ">>>>> setup hostname"
}