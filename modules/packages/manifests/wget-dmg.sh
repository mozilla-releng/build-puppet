#! /bin/bash

set -e

if ! test -f wget.spec; then
    echo "Run this from the root of the unpacked SRPM (it uses the sources)"
    exit 1
fi

# variables to parallel the spec file
realname=wget
version=1.12
release=1

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

# %prep
tar -zxf ../$realname-$version.tar.bz2
cd $realname-$version

# %build
./configure
make -j2

# %install
ROOT=$BUILD/root
make install DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin


# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/Volumes/Auxiliary\ Tools/PackageMaker.app/Contents/MacOS/PackageMaker  -r $ROOT -v -i com.mozilla.$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
