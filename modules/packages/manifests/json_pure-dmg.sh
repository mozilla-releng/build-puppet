#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This is required for Puppet on Mountain Lion
#  - https://tickets.puppetlabs.com/browse/PUP-2616
#  - http://docs.puppetlabs.com/guides/install_puppet/install_osx.html
# N.B. This will only work on Mountain Lion (and maybe Lion, but it's not needed there),
# as Mavericks and higher don't have Ruby-1.8 installed.

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

VERSION=1.8.1
URL="https://github.com/flori/json/archive/v${VERSION}.tar.gz"

SITELIBDIR=installroot/Library/Ruby/Site/1.8

set -e

curl -L -o tarball.tar.gz $URL
tar -xvf tarball.tar.gz

# just copy the files in - that's all install.rb does anyway
mkdir -p $SITELIBDIR
mv json-$VERSION/lib/json.rb $SITELIBDIR/json.rb
mv json-$VERSION/lib/json/ $SITELIBDIR/json/

PACKAGE_MAKER="/usr/bin/pkgbuild"

DIR_TO_PACKAGE=$SITELIBDIR
PACKAGE_BASENAME=json_pure-$VERSION
PACKAGE_SHORTNAME=json_pure-$VERSION
INSTALLDIR=/Library/Ruby/Site/1.8

if [[ ! -x $PACKAGE_MAKER ]]; then
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

$PACKAGE_MAKER -r $DIR_TO_PACKAGE -i com.mozilla.$PACKAGE_SHORTNAME --install-location $INSTALLDIR $tmp/$PACKAGE_BASENAME.pkg
rm -rf $tmp/`basename $DIR_TO_PACKAGE`
hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
echo DMG is at $PWD/$PACKAGE_BASENAME.dmg
