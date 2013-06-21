#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

set -e

# build UCL first
curl -LO http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz
tar zxf ucl-1.03.tar.gz
pushd ucl-1.03
./configure --prefix=/usr/local
make
# UPX just reads from the built source
popd

curl -LO http://upx.sourceforge.net/download/00-OLD-VERSIONS/upx-3.05-src.tar.bz2
tar zxf upx-3.05-src.tar.bz2
pushd upx-3.05-src
export UPX_UCLDIR="$PWD/../ucl-1.03"
make all
popd

# there's no "make install".  And the binary is called 'upx.out'.  Seriously.
mkdir -p installroot/usr/local/bin
cp upx-3.05-src/src/upx.out installroot/usr/local/bin/upx

# -- create-dmg.sh

PACKAGE_MAKER="/Developer/usr/bin/packagemaker"

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=upx-3.05
PACKAGE_SHORTNAME=upx305
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
echo DMG is at ./$PACKAGE_BASENAME.dmg
