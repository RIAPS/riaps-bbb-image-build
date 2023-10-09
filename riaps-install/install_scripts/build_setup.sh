#!/usr/bin/env bash
set -e


# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo pip3 install --upgrade pip
    echo ">>>>> installed upgrade pip3"
}

cython_install() {
    start=`date +%s`
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.29.36' --verbose
    end=`date +%s`
    echo ">>>>> installed cython"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

