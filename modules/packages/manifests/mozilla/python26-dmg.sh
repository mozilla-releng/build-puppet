#! /bin/bash

## DIFFERENCES FROM RPM:
# - no tk, tcl bindings (not installed)
# - no readline (not detected at build time)

set -e

if ! test -f python26.spec; then
    echo "Run this from the root of the unpacked SRPM (it uses the sources)"
    exit 1
fi

# variables to parallel the spec file
realname=python26
pyver=2.6
pyrel=7
release=1
_prefix=/tools/$realname
_libdir=$_prefix/lib

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

# %prep
tar -jxf ../Python-$pyver.$pyrel.tar.bz2
cd Python-$pyver.$pyrel
patch -p0 < ../../python-2.6-fix-cgi.patch

# %build
## TODO - mac way - export LDFLAGS="-Wl,-rpath=$_libdir"
./configure --prefix=$_prefix --libdir=$_libdir \
    --enable-ipv6 --enable-shared --with-system-ffi --with-system-expat
make -j2

# %install
ROOT=$BUILD/root
make altinstall DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin
ln -s $_prefix/bin/python$pyver $ROOT/usr/local/bin/python$pyver

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$realname-$pyver.$pyrel-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/Developer/usr/bin/packagemaker -r $ROOT -v -i com.mozilla.$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-Python-$pyver.$pyrel-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
