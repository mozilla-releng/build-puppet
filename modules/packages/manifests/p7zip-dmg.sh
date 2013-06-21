#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

curl -LO "http://downloads.sourceforge.net/project/p7zip/p7zip/9.20.1/p7zip_9.20.1_src_all.tar.bz2"
tar jxf p7zip_9.20.1_src_all.tar.bz2
cd p7zip_9.20.1
cp makefile.macosx_64bits makefile.machine
make all_test
sed -e "s/^DEST_DIR=$/DEST_DIR=installroot/" < install.sh | sh

# -- create-dmg.sh

PACKAGE_MAKER="/Developer/usr/bin/packagemaker"

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=p7zip-9.20.1
PACKAGE_SHORTNAME=7z9201
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
echo "DMG is at" "$PWD/$PACKAGE_BASENAME.dmg"
