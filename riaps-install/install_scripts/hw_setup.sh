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
    echo "# Enable OOM-Killer" >> /etc/sysctl.conf
    echo "# Added for RIAPS Platform (10/25/21, MM)" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
    echo "kernel.panic = 5" >> /etc/sysctl.conf
    echo "vm.oom-kill = 1" >> /etc/sysctl.conf
    echo ">>>>> added watchdog timer values"
}

setup_hostname() {
    cp usr/bin/set_unique_hostname /usr/bin/set_unique_hostname
    sudo chmod +x /usr/bin/set_unique_hostname
    cp etc/systemd/system/sethostname.service /etc/systemd/system/sethostname.service
    systemctl enable sethostname.service
    systemctl start sethostname.service
    echo ">>>>> setup hostname"
}

setup_peripherals() {
    getent group gpio ||groupadd gpio
    getent group dialout ||groupadd dialout
    getent group pwm ||groupadd pwm
    #getent group spi ||groupadd spi
    echo ">>>>> setup peripherals - gpio, uart, pwm and spi"
}

# To create an image with a date close to the creation date
set_date() {
    sudo rdate -n -4 time.nist.gov
}