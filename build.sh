#!/bin/bash -e
# Build RIAPS BBB image

# Make sure that omap-image-builder submodule is initialized
git submodule update --init
git submodule foreach git reset --hard # Reset any changes to submodules
rm -rf omap-image-builder/deploy/      # Remove any existing builds

# Copy RIAPS files into omap-image-builder repo
cp riaps-jammy.conf omap-image-builder/configs/
cp riaps_setup.sh omap-image-builder/target/chroot/
cp riaps.sh omap-image-builder/target/chroot/
cp -r riaps-install omap-image-builder/

# Build ubuntu filesystem
cd omap-image-builder
git apply ../omap-image-builder.patch
./RootStock-NG.sh -c riaps-jammy

# Build image for BBB
filesize=8gb
IMG=$(basename $(find deploy -maxdepth 1 -type f -name "*.tar" -print -quit) .tar)
echo "Image name: $IMG"
cd "deploy/$IMG"
sudo ./setup_sdcard.sh --img-${filesize} $IMG --dtb beaglebone --distro-bootloader --rootfs_label rootfs --enable-cape-universal
zip $IMG-${filesize}.zip *.img
mv *.zip ../../../
