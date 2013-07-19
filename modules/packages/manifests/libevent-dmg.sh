#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD
export PATH=`xcode-select -print-path`:/tools/packagemaker/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

version=2.0.21-stable
shortver=2021s

curl -LO "https://github.com/downloads/libevent/libevent/libevent-$version.tar.gz"
tar zxf libevent-$version.tar.gz
cd libevent-$version
./configure
make
ROOT=$BUILD/root
make install DESTDIR=$ROOT
find $ROOT

# -- create-dmg.sh

cd $BUILD
mkdir dmg
fullname=libevent-$version
shortver=libevent2021
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
packagemaker -r $ROOT -v -i org.libevent.$shortver -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "$fullname" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg

