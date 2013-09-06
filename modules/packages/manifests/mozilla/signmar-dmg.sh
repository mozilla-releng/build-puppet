#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

##### NOTE: do not run this on the target version of OS X.  Instead, run it
##### on an updated builder system, of whatever variety was used to build this
##### version of Firefox

set -e -x

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD
export PATH=`xcode-select -print-path`:/tools/packagemaker/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# note that each version of Firefox pretty much requires a very specific version of clang.  Look in the build logs for that release
# and find the tooltool sha512 for that version of clang.  Unfortunately, tooltool is still not externally accessible, so you'll
# need to ask someone with access to get the file for you, if you're building this outside of moco.
version=23.0
# r170890
clang_sha512=e156e2a39abd5bf272ee30748a6825f22ddd27565b097c66662a2a6f2e9892bc5b4bf30a3552dffbe867dbfc39e7ee086e0b2cd7935f6ea216c0cf936178a88f

# this may differ if you build from a nightly or dep build
tarballdir=mozilla-release

url=https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}/source/firefox-${version}.source.tar.bz2

[ -f source.tgz ] || curl -v $url > source.tgz
tar -jxf source.tgz
cd $tarballdir

# get the version of clang that works with this build
curl -v -o clang.tar.bz2 http://tooltool.pvt.build.mozilla.org/build/sha512/$clang_sha512
tar -jxf clang.tar.bz2

# and patch out a bug in the configure script which ignores --disable-webm
sed -i -e '/You may either install yasm or --disable-webm/s/.*/:/g' configure

cat <<EOF >.mozconfig
CC="$PWD/clang/bin/clang"
CXX="$PWD/clang/bin/clang++"
mk_add_options MOZ_MAKE_FLAGS=-j4
ac_add_options --enable-debug
ac_add_options --disable-optimize
ac_add_options --enable-tests
ac_add_options --enable-metro
ac_add_options --enable-profiling
ac_add_options --enable-signmar
EOF

make -f client.mk

# install by hand, including library files
cd $BUILD/$tarballdir/obj-*
ROOT=$BUILD/root
install -dm 755 $ROOT/tools/signmar/bin

# install signmar
install -m 755 dist/bin/signmar $ROOT/tools/signmar/bin

# and drop in some libs it loads at runtime; these need to be in the same dir as the executable
install -m 755 dist/bin/libfreebl3.dylib $ROOT/tools/signmar/bin
install -m 755 dist/bin/libnssdbm3.dylib $ROOT/tools/signmar/bin
install -m 755 dist/bin/libsoftokn3.dylib $ROOT/tools/signmar/bin

# repeatedly iterate through dependencies
did_install=true
while $did_install; do
        did_install=false
        for lib in $(otool -L $ROOT/tools/signmar/bin/* | grep @executable_path | sed 's!@executable_path/\([^ ]*\) .*!\1!'); do
                if [ ! -f $ROOT/tools/signmar/bin/$lib ]; then
                        did_install=true
                        install dist/bin/$lib $ROOT/tools/signmar/bin
                fi
        done
done

install -dm 755 $ROOT/usr/local/bin
ln -s /tools/signmar/bin/signmar $ROOT/usr/local/bin

cd $BUILD
mkdir dmg
fullname=signmar-$version
shortname=$(echo $fullname | tr -dc 'a-z0-9')
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
packagemaker -r $ROOT -v -i org.libevent.$shortname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "$fullname" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
