#!/usr/bin/env bash
set -e


# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo pip3 install --upgrade pip
    echo ">>>>> installed upgrade pip3"
}

cython_install() {
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.29.21' --verbose
    echo ">>>>> installed cython"
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD
    mkdir -p /tmp/3rdparty/build
    cp CMakeLists.txt /tmp/3rdparty/.
    cd /tmp/3rdparty/build
    cmake -Darch=${NODE_ARCH} ..
    make
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/
    echo ">>>>> cmake install complete"
}
