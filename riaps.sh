#!/bin/bash -e
# RIAPS setup script to be called from inside the chroot
# Called by chroot.sh after intializing the root filesystem

export LC_ALL=C

cd /opt/riaps-install
/bin/bash elinux.sh
/bin/bash base_bbb_bootstrap.sh




WORK IN PROGRESS...
Need to add somewhere in this process
make sure to remove Cython3 first
if ! pip3 list | grep Cython | grep 0.28.5; then
    echo "Updating Cython to 0.28.5"
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.28.5'
fi

rm -rf /tmp/pyzmq
git clone https://github.com/zeromq/pyzmq.git /tmp/pyzmq
cd tmp/pyzmq
git checkout tags/v17.1.2
python3 setup.py install
rm -rf /tmp/pyzmq

pip3 install 'pybind11==2.2.4'



CFLAGS=-I/opt/riaps/armhf/include LDFLAGS=-L/opt/riaps/armhf/lib PATH=$PATH:/opt/riaps/armhf/bin pip3 install 'pycapnp==0.6.3'
CFLAGS=-I/opt/riaps/armhf/include LDFLAGS=-L/opt/riaps/armhf/lib PATH=$PATH:/opt/riaps/armhf/bin pip3 install /opt/riaps/armhf/bindings/czmq/python/ --verbose
CFLAGS=-I/opt/riaps/armhf/include LDFLAGS=-L/opt/riaps/armhf/lib PATH=$PATH:/opt/riaps/armhf/bin pip3 install /opt/riaps/armhf/bindings/zyre/python/ --verbose


NOTE: This might already be somewhere...
rm -rf /tmp/spdlog-python
git clone https://github.com/RIAPS/spdlog-python.git /tmp/spdlog-python
cd /tmp/spdlog-python
git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
python3 setup.py install
rm -rf /tmp/spdlog-python
NOTE...

CAPNPROTO:
git clone https://github.com/capnproto/capnproto
git checkout v0.6.1
autoreconf -i
./configure --enable-shared
make
sudo make install

CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3'

LMDB:
git clone https://github.com/LMDB/lmdb.git
cd lmdb/libraries/liblmdb
git checkout LMDB_0.9.24
make
sudo make install


TO HERE...
