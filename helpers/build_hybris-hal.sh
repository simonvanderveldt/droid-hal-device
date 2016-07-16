#!/bin/bash
# build_hybris-hal.sh - takes care of (re)building hybris-hal (kernel + initrd)

source build/envsetup.sh
USE_CCACHE=1
breakfast $DEVICE
rm .repo/local_manifests/roomservice.xml
make hybris-hal
