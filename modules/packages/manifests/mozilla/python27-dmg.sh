#! /bin/bash

## DIFFERENCES FROM RPM:
# - no tk, tcl bindings (not installed)
# - no readline (not detected at build time)

set -e

if ! test -f python27.spec; then
    echo "Run this from the root of the unpacked SRPM (it uses the sources)"
    exit 1
fi

# variables to parallel the spec file
realname=python27
pyver=2.7
pyrel=3
release=1
_prefix=/tools/$realname
_libdir=$_prefix/lib

# use the current xcode, and include the packages::packagemaker path
export PATH=`xcode-select -print-path`:/tools/packagemaker/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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
# see https://bugzilla.mozilla.org/show_bug.cgi?id=882869#c17
patch -p1 < ../../python27-issue_13370-2.patch
# see http://bugs.python.org/issue1602133
patch -p1 < ../../python27-issue1602133.patch

# %build
# --without-system-ffi is required here, or ctypes breaks; see
# https://bugzilla.mozilla.org/show_bug.cgi?id=882869#c17
./configure --prefix=$_prefix --libdir=$_libdir \
    --enable-ipv6 --enable-shared --without-system-ffi --with-system-expat
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
packagemaker -r $ROOT -v -i com.mozilla.$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-Python-$pyver.$pyrel-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
