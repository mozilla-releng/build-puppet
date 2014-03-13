#! /bin/bash

VERSION=0.10.21

if test -d build; then
rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

set -e

mkdir dmg

# note that we slightly rename the package file from what's on nodejs.org
fullname=nodejs-$VERSION

# download the .pkg from nodejs.org
curl -o dmg/$fullname.pkg http://nodejs.org/dist/v$VERSION/node-v$VERSION.pkg

# expand and re-flatten to eliminate the signature, which Mountain Lion cannot verify
pkgutil --expand dmg/$fullname.pkg expanded
pkgutil --flatten expanded dmg/$fullname.pkg

hdiutil makehybrid -hfs -hfs-volume-name "nodejs-$VERSION" -o ./$fullname.dmg dmg
echo DMG is at $PWD/$fullname.dmg
