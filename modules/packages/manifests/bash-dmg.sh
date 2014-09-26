#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

MOZ_SUFFIX=-moz2
APPLE_VERSION=92

osx_vers=10.7.2  # convenient since it's a builder; not sure if this is important
if [ "$(sw_vers -productVersion)" != "$osx_vers" ]; then
    echo "Build this on a $osx_vers host"
    exit 1
fi

xcode_vers=4.1  # again, this is what was easiest, but probably anything would work
if [ "$(xcodebuild -version | grep Xcode)" != "Xcode $xcode_vers" ]; then
    echo "Build this with Xcode $xcode_vers"
    exit 1
fi

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

set -e
set -x

curl -O https://opensource.apple.com/tarballs/bash/bash-${APPLE_VERSION}.tar.gz
tar -xvf bash-${APPLE_VERSION}.tar.gz
pushd bash-${APPLE_VERSION}

pushd bash-3.2

# shellshocked patches -- note this was handled *terribly* and it's not entirely clear
# which patch fixes which vulnerabilities.  However, bash-054 is "Florian's Patch" which
# avoids sending variable content to the parser and should sidestep parser issues.  At
# least two such issues are known - CVE-2014-7186 and CVE-2014-7187.

# patch for CVE-2014-6271 -- incomplete
curl https://ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-052 | patch -p0
# patch for CVE-2014-7169 -- fix to -6271
curl https://ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-053 | patch -p0
# "Florian's Patch"
curl https://ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-054 | patch -p0

popd


xcodebuild
popd

mkdir -p root/usr/bin
cp bash-${APPLE_VERSION}/build/Release/{bash,sh} root/usr/bin

PACKAGE_MAKER="/usr/bin/pkgbuild"
PACKAGE_BASENAME=bash-3.2$MOZ_SUFFIX
PACKAGE_SHORTNAME=bash-32$MOZ_SUFFIX

if [[ ! -x $PACKAGE_MAKER ]]; then
    echo "Couldn't find pkgbuild"
    exit 1
fi

mkdir dmg
$PACKAGE_MAKER --root root -i com.mozilla.$PACKAGE_SHORTNAME --install-location / dmg/$PACKAGE_BASENAME.pkg

hdiutil makehybrid -hfs -hfs-volume-name "$PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg dmg
echo DMG is at $PWD/$PACKAGE_BASENAME.dmg
