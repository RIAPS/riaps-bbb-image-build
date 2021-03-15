#!/bin/bash -e
# RIAPS setup script to be called from inside the chroot
# Called by chroot.sh after intializing the root filesystem

export LC_ALL=C

cd /opt/riaps-install
/bin/bash elinux.sh
#MM TODO: remove for now to determine if kernel works - trying with newer qemu (03/14/21)
/bin/bash base_bbb_bootstrap.sh
