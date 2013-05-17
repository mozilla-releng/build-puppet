#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## WARNING: This script is based on https://bugzilla.mozilla.org/show_bug.cgi?id=720470#c13
## and generates a working DMG, but the DMG currently in the puppet repos was built by hand,
## not by this script.

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

curl -LO http://samba.org/ftp/ccache/ccache-3.1.7.tar.bz2
tar jxf ccache-3.1.7.tar.bz2
cd ccache-3.1.7
./configure --prefix=/usr/local
make
make install DESTDIR=installroot

# -- create-dmg.sh

PACKAGE_MAKER="/Developer/usr/bin/packagemaker"

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=ccache-3.1.7
PACKAGE_SHORTNAME=ccache317
INSTALLDIR=/usr/

if [[ -z $DIR_TO_PACKAGE || -z $PACKAGE_BASENAME || -z $PACKAGE_SHORTNAME || -z $INSTALLDIR ]]; then
    echo "Usage: $0 dir-to-package package-base-name package-short-name installdir"
    exit 1
fi
if [[ ! -x $PACKAGE_MAKER ]]; then
    echo "Couldn't find packagemaker"
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
echo $PACKAGE_MAKER -r $tmp -v -i com.mozilla.$PACKAGE_SHORTNAME -o $tmp/$PACKAGE_BASENAME.pkg -l $INSTALLDIR
$PACKAGE_MAKER -r $tmp -v -i com.mozilla.$PACKAGE_SHORTNAME -o $tmp/$PACKAGE_BASENAME.pkg -l $INSTALLDIR
rm -rf $tmp/`basename $DIR_TO_PACKAGE`
echo hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
