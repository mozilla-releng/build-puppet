#!/bin/bash
set -e

# NOTE: you must make/compile this on 10.6 in order for this to work on 10.6+

BUILD=$PWD/build
ROOT=$BUILD/installroot
OUT=dmg

REALNAME=xz
VER=5.2.3
PACKAGE_FULLNAME=$REALNAME-$VER
PACKAGE_SHORTNAME=${REALNAME}523
TAR=$REALNAME.tar.bz2
URL="https://downloads.sourceforge.net/project/lzmautils/xz-5.2.3.tar.bz2?r=https%3A%2F%2Ftukaani.org%2Fxz%2F&ts=1501281259&use_mirror=ayera"

# Clean build dir
if [ -d $BUILD ]; then
    rm -rf $BUILD
fi
mkdir $BUILD
cd $BUILD

# Download xz.tar.bz2
curl -Lo $TAR $URL

# unpack
tar -xjvf $TAR

# compile source
cd $PACKAGE_FULLNAME
./configure
mkdir -p $ROOT/usr/
make

# install
make prefix=$ROOT/usr/ install
cd ..

# Make package
mkdir -p $OUT
PKG=$OUT/$PACKAGE_FULLNAME.pkg
DMG=$PACKAGE_FULLNAME.dmg
pkgbuild --root $ROOT --identifier org.$REALNAME.$REALNAME --install-location / $PKG

# make dmg
hdiutil makehybrid -hfs -hfs-volume-name "${PACKAGE_FULLNAME}" -o ./$DMG $OUT
echo "Result:"
echo $PWD/$DMG
