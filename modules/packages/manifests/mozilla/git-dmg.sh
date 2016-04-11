#! /bin/bash

set -e

realname=git
version=2.7.4
release=3
_prefix=/tools/$realname
URL="https://www.kernel.org/pub/software/scm/git/git-${version}.tar.gz"

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

curl -LO $URL

# %prep
tar -zxf $realname-$version.tar.gz
cd $realname-$version

# %build
./configure --prefix=$_prefix
make -j2 

# %install
ROOT=$BUILD/root
make install DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin
ln -s $_prefix/bin/git $ROOT/usr/local/bin/git

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
pkgbuild --root $ROOT --identifier com.mozilla.$realname  --install-location / $pkg
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
