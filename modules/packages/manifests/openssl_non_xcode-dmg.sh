#!/bin/bash
set -e

BUILD=$PWD/build
ROOT=$BUILD/installroot
OUT=dmg

REALNAME=openssl
VER=1.0.2l
PACKAGE_FULLNAME=$REALNAME-$VER
PACKAGE_SHORTNAME=${REALNAME}523
TAR=$REALNAME.tar.gz
URL="https://www.openssl.org/source/openssl-${VER}.tar.gz"

# Clean build dir
if [ -d $BUILD ]; then
    rm -rf $BUILD
fi
mkdir $BUILD
cd $BUILD

# Download
curl -Lo $TAR $URL

# unpack
tar -zxvf $TAR

# compile source
cd $PACKAGE_FULLNAME
export KERNEL_BITS=64
./configure shared darwin64-x86_64-cc --prefix=/opt/local --openssldir=/opt/local
mkdir -p $ROOT/opt/local
make

# install
make INSTALL_PREFIX=$ROOT install
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
