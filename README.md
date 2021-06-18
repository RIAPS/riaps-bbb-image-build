# riaps-bbb-image-build

## How to build an image:
```
git clone https://github.com/RIAPS/riaps-bbb-image-build.git
cd riaps-bbb-image-build
chmod +x build.sh
./build.sh
```

>Note: The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.

## How to update the version of omap-image-builder
```
git clone https://github.com/RIAPS/riaps-bbb-image-build.git
cd riaps-bbb-image-build
git submodule update --init   # Clones omap-image-builder into local repo
cd omap-image-builder
git checkout <tag>            # Where <tag> is the version which you want to move to
# Now the riaps-bbb-image-build repo will recognize that omap-image-builder is a newer version
# A commit on riaps-bbb-image-build will now pin this new version
```
- When moving to a new kernel version, the version number simply needs to be updated and the new version will be installed. In riaps-focal.conf, **repo_rcnee_pkg_list** and **repo_rcnee_pkg_version** need to contain the new kernel version.

To update the **omap-image-builder.patch** file: make changes in updated repository and then do following to get the new file:

```
git diff > omap-image-builder.patch
```

## File explanation
- riaps-focal.conf: This file is modeled after the files inside omap-image-builder/config. It tells the builder which packages need to be installed in the newly generated image.
- riaps-install/: This folder will be copied into the image at /opt/riaps-install/. Any files which need to be available from inside the image, need to be inside this folder.
- riaps_setup.sh: Script which is automatically called from outside the chroot, before the image is fully setup. This script can copy files such as riaps-install/ into the chroot directory.
- riaps.sh: Script which is called from inside the chroot. Responsible for performing RIAPS configuration from inside the virtual environment.
