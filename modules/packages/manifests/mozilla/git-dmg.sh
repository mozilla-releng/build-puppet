#! /bin/bash

set -e

if ! test -f git.spec; then
    echo "Run this from the root of the unpacked SRPM (it uses the sources)"
    exit 1
fi

# variables to parallel the spec file
realname=git
version=1.7.9.4
release=1
_prefix=/tools/$realname

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

# %prep
tar -zxf ../$realname-$version.tar.gz
cd $realname-$version

# %build
./configure --prefix=$_prefix
make -j2 

# %install
ROOT=$BUILD/root
make install DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin
ln -s $_prefix/bin/git* $ROOT/usr/local/bin/git

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg 
fullname=$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/Developer/usr/bin/packagemaker -r $ROOT -v -i com.mozilla.$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
