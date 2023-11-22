#!/usr/bin/env bash
set -e

# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo pip3 install --upgrade pip
    echo ">>>>> installed upgrade pip3"
}

apparmor_monkeys_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/apparmor_monkeys.git $TMP/apparmor_monkeys
    cd $TMP/apparmor_monkeys
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed apparmor_monkeys"
}

pyzmq_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/pyzmq.git $TMP/pyzmq
    cd $TMP/pyzmq
    git checkout v23.2.1
    ZMQ_DRAFT_API=1 ZMQ_PREFIX=$RIAPS_PREFIX sudo -E pip install . -v --no-binary pyzmq --pre pyzmq --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed pyzmq"
}

# Install bindings for czmq. Must be run after pyzmq, czmq install.
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq_pybindings
    cd $TMP/czmq_pybindings/bindings/python
    git checkout v4.2.1
    ZMQ_PREFIX=$RIAPS_PREFIX sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed CZMQ pybindings"
}

# Install bindings for zyre. Must be run after zyre, pyzmq install.
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre_pybindings
    cd $TMP/zyre_pybindings/bindings/python
    git checkout v2.0.1
    ZMQ_PREFIX=$RIAPS_PREFIX sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed Zyre pybindings"
}

# Link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    sudo pip3 install pkgconfig
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    #git clone https://github.com/capnproto/pycapnp.git $TMP/pycapnp
    git clone https://github.com/LasseBlaauwbroek/pycapnp.git $TMP/pycapnp
    cd $TMP/pycapnp
    git checkout upgrade-cython
    # Force this release to use Cython 0.29.36, otherwise it tries Cython 3.x and fails
    # Note: newer versions pf pycapnp add this restriction 
    #sed -i 's/cython/cython<3/g' pyproject.toml
    sudo pip3 install . -C force-system-libcapnp=True --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed pycapnp with system built capnproto"
}

# Install prctl package
prctl_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/python-prctl.git $TMP/python-prctl
    cd $TMP/python-prctl/
    git checkout feature-ambient
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed prctl"
}

py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jnwatson/py-lmdb.git $TMP/py_lmdb
    cd $TMP/py_lmdb
    git checkout py-lmdb_1.3.0
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf $TMP
}

# These are packages that should be installed separately from the packages listed in
# python3_pkgs= section of the .conf file
#     Packages needed are: paramiko (3.3.1), pynacl and fabric2 (3.2.2)
#     - pynacl has a conflict between distribution install cffi (1.15.0) and the 
#       latest version it pulls (1.16.0) when installing with python3_pkgs. "butter" 
#       updates the cffi version to 1.16.0, so the install works here since the version check 
#       is not longer conflicting.  Note: did not see this issue the VM which has cffi=1.5.0. 
#     - Packages desired here, but built manually on a BBB setup for now
#       * paramiko has issues build in 32-bit qemu environment on a 64-bit host
#       * fabric2 requires paramiko
pip3_additional_installs(){
    start=`date +%s`

    pip3 install 'pynacl==1.5.0' --verbose

    end=`date +%s`
    echo ">>>>> installed additional pip3 packages"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}
