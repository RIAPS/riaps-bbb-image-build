#!/bin/bash -e
# Build RIAPS BBB image

# Make sure that omap-image-builder submodule is initialized
git submodule update --init

# Copy RIAPS files into omap-image-builder repo
cp riaps-bionic.conf omap-image-builder/configs/
cp riaps_setup.sh omap-image-builder/target/chroot/
cp riaps.sh omap-image-builder/target/chroot/
cp -r riaps-install omap-image-builder/
cp omap-image-builder.patch omap-image-builder/

# Build ubuntu filesystem
cd omap-image-builder
git apply omap-image-builder.patch
./RootStock-NG.sh -c riaps-bionic

# Build image for BBB
IMG=$(\ls deploy)
cd deploy/$IMG
sudo ./setup_sdcard.sh --img-4gb $IMG --dtb beaglebone
mv *.img ../../../
