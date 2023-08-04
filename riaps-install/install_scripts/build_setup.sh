#!/usr/bin/env bash
set -e


# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo python -m pip3 install --upgrade pip
    echo ">>>>> installed upgrade pip3"
}

cython_install() {
    start=`date +%s`
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.29.32' --verbose
    end=`date +%s`
    echo ">>>>> installed cython"
        diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD
    mkdir -p /tmp/3rdparty/build
    cp CMakeLists.txt /tmp/3rdparty/.
    cd /tmp/3rdparty/build
    cmake ..
    make
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/
    echo ">>>>> cmake install complete"
}
