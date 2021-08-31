#!/usr/bin/env bash
set -e


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

setup_peripherals() {
    getent group gpio ||groupadd gpio
    getent group dialout ||groupadd dialout
    getent group pwm ||groupadd pwm
    #getent group spi ||groupadd spi
    echo ">>>>> setup peripherals - gpio, uart, pwm and spi"
}
