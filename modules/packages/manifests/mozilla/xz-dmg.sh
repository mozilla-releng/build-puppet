#! /bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

# variables to parallel the spec file
realname=xz
xzver=5.2
xzrel=4
release=1

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

cp ../xz-$xzver.$xzrel.tar.gz .

# %prep
tar -zxvf xz-$xzver.$xzrel.tar.gz
cd xz-$xzver.$xzrel

# %build
./configure 
#make clean
make

# %install
ROOT=$BUILD/root
make install DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$realname-$xzver.$xzrel-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/usr/bin/pkgbuild -r $ROOT -i com.mozilla.$realname --install-location / $pkg
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-xz-$xzver.$xzrel-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
