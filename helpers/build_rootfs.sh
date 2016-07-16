#!/bin/bash
# build_packages.sh - takes care of rebuilding droid-hal-device, -configs, and
# -version, as well as any middleware packages. All in correct sequence, so that
# any change made (e.g. to patterns) could be simply picked up just by
# re-running this script.
#
# Copyright (C) 2015 Alin Marin Elena <alin@elena.space>
# Copyright (C) 2015 Jolla Ltd.
# Contact: Simonas Leleiva <simonas.leleiva@jollamobile.com>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

if [ -z $DEVICE ]; then
    echo 'Error: $DEVICE is undefined. Please run hadk'
    exit 1
fi

if [[ ! -d rpm/helpers && ! -d rpm/dhd ]]; then
    echo $0: launch this script from the $ANDROID_ROOT directory
    exit 1
fi

if [ ! -d rpm/dhd ]; then
    echo "rpm/dhd/ does not exist, please run migrate first."
    exit 1
fi

echo "Creating Kickstart file"
HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
sed -e \
"s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
$ANDROID_ROOT/hybris/droid-configs/installroot/usr/share/kickstarts/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks \
> tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

echo "Updating patterns"
hybris/droid-configs/droid-configs-device/helpers/process_patterns.sh || true

echo "Creating rootfs"
# Set the version of your choosing, latest is strongly preferred
# (check with "Sailfish OS versions" link above)
RELEASE=1.1.7.28
# EXTRA_NAME adds your custom tag. It doesn’t support ’.’ dots in it!
EXTRA_NAME=-my1
sudo mic create fs --arch armv7hl \
--tokenmap=ARCH:armv7hl,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME \
--record-pkgs=name,url \
--outdir=sfe-$DEVICE-$RELEASE$EXTRA_NAME \
--pack-to=sfe-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 \
$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks
