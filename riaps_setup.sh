#!/bin/bash -e
# early_chroot_script called by chroot.sh
# Called before entering chroot
# Copies required RIAPS files and directories into chroot directory
# Based on omap-image-builder/target/chroot/early_chroot_script.sh
# @args <tmp_dir> The chroot directory

export LC_ALL=C

sudo cp -r riaps-install $1/opt/
sudo cp target/chroot/elinux-arm64.sh $1/opt/riaps-install/