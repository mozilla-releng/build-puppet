#! /bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## DIFFERENCES FROM RPM:
# - no tk, tcl bindings (not installed)
# - no readline (not detected at build time)

set -e

# variables to parallel the spec file
realname=python36
pyver=3.6
pyrel=5
release=2
_prefix=/tools/$realname
_libdir=$_prefix/lib
srpm_release=2  # use whatever version of the SRPM is on the server

# ensure the same build environment (you can change this if necessary, just test carefully)

# --without-system-ffi is required here, or ctypes breaks; see
# https://bugzilla.mozilla.org/show_bug.cgi?id=882869#c17
ffi_option=--without-system-ffi
shared_option=--enable-shared
case "$(sw_vers -productVersion)" in
    10.7) ;;  # ?? lost to the sands of time
    10.8) ;;  # ?? lost to the sands of time
    10.9) ;;  # ?? lost to the sands of time
    10.10)
        # This was built with XCode 6.1 command line tools, but that version of XCode no longer
        # supports a way to find its version on the command line.

        # The built-in ffi fails on Yosemite
        ffi_option=
        # and --enable-shared appears to fail, too..
        shared_option=
        ;;
esac

# use the current xcode
export PATH=`xcode-select -print-path`:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

# get the sources from the SRPM and some local patches
curl http://puppet/repos/yum/custom/mozilla-python36/x86_64/mozilla-python36-$pyver.$pyrel-$srpm_release.el6.src.rpm | bsdtar -x

# %prep
tar -jxf Python-$pyver.$pyrel.tar.xz
cd Python-$pyver.$pyrel
patch -p0 < ../python-2.6-fix-cgi.patch

# %build
./configure --prefix=$_prefix --libdir=$_libdir \
    --enable-ipv6 $shared_option --with-system-expat $ffi_option
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
/usr/bin/pkgbuild -r $ROOT -i com.mozilla.$realname --install-location / $pkg
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-Python-$pyver.$pyrel-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
