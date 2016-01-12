#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

## WARNING: This script is based on https://bugzilla.mozilla.org/show_bug.cgi?id=720470#c4
## and generates a working DMG, but the DMG currently in the puppet repos was built by hand,
## not by this script.

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

VERSION=1.3.0
SHA2=3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f
curl -LO https://www.tortall.net/projects/yasm/releases/yasm-$VERSION.tar.gz
CHECKSUM=$(shasum -a 256 yasm-$VERSION.tar.gz | cut -d ' ' -f 1)
if [[ $SHA2 != "$CHECKSUM" ]]; then
  echo "CHECKSUM MISMATCH! download wasn't as expected"
  echo "expected $SHA2"
  echo "     got $CHECKSUM"
  exit 1
else
  echo "Checksum matches"
fi

tar zxf yasm-$VERSION.tar.gz
cd yasm-$VERSION
./configure --prefix=/usr/local
make
make install DESTDIR=installroot

# -- create-dmg.sh

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=yasm-$VERSION
PACKAGE_SHORTNAME=yasm$(echo $VERSION | sed -e 's/\.//g')
INSTALLDIR=/usr/

if [[ -z $DIR_TO_PACKAGE || -z $PACKAGE_BASENAME || -z $PACKAGE_SHORTNAME || -z $INSTALLDIR ]]; then
    echo "Usage: $0 dir-to-package package-base-name package-short-name installdir"
    exit 1
fi
if [[ ! -x $(which pkgbuild) ]]; then
    echo "Couldn't find pkgbuild"
    exit 1
fi
if [[ ! -d $DIR_TO_PACKAGE ]]; then
    echo "$DIR_TO_PACKAGE doesn't exist or isn't readable"
    exit 1
fi
if [[ -e $PACKAGE_BASENAME.dmg ]]; then
    echo "$PACKAGE_BASENAME.dmg already exists"
    exit 1
fi

DIR_TO_PACKAGE=${DIR_TO_PACKAGE%/}
tmp=`mktemp -d -t magic`

trap "rm -rf $tmp" EXIT

rsync -av $DIR_TO_PACKAGE $tmp
pkgbuild --root $tmp --identifier com.mozilla.$PACKAGE_SHORTNAME \
  --version $VERSION --install-location $INSTALLDIR \
  $tmp/$PACKAGE_BASENAME.pkg
rm -rf $tmp/`basename $DIR_TO_PACKAGE`
hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
echo "Disk image is ready at" "$PWD/$PACKAGE_BASENAME.dmg"
