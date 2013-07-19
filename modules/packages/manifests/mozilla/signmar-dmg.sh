#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e -x

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD
export PATH=`xcode-select -print-path`:/tools/packagemaker/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

version=19.0
# this may differ if you build from a nightly or dep build
tarballdir=mozilla-release

url=https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}/source/firefox-${version}.source.tar.bz2

[ -f source.tgz ] || curl -v $url > source.tgz
tar -jxf source.tgz
cd $tarballdir

# patch in security (which includes nss) to the tools/update-packaging application
patch -p0 <<'EOF'
--- tools/update-packaging/build.mk~	2013-07-22 10:53:44.000000000 -0700
+++ tools/update-packaging/build.mk	2013-07-22 10:54:03.000000000 -0700
@@ -7,6 +7,8 @@
 TIERS += app
 
 tier_app_dirs += \
+	db/sqlite3/src \
+	security/build \
 	modules/libbz2 \
 	modules/libmar \
 	other-licenses/bsdiff \
EOF

# and patch out a bug in the configure script which ignores --disable-webm
sed -i -e '/You may either install yasm or --disable-webm/s/.*/:/g' configure

cat <<EOF >.mozconfig
CXX='clang++ -std=c++11'
ac_add_options --enable-application=tools/update-packaging
ac_add_options --without-system-ply
ac_add_options --without-system-libxul
ac_add_options --without-system-libevent
ac_add_options --without-system-nspr
ac_add_options --without-system-nss
ac_add_options --without-system-jpeg
ac_add_options --disable-libjpeg-turbo
ac_add_options --without-system-zlib
ac_add_options --without-system-bz2
ac_add_options --without-system-png
ac_add_options --disable-system-hunspell
ac_add_options --disable-system-ffi
ac_add_options --without-system-libvpx
ac_add_options --disable-system-sqlite
ac_add_options --disable-system-cairo
ac_add_options --disable-system-pixman
ac_add_options --disable-skia
ac_add_options --disable-webm
# any of these cause the build to fail
#ac_add_options --disable-crashreporter
#ac_add_options --disable-ogg
ac_add_options --disable-wave
ac_add_options --enable-signmar
EOF

make -f client.mk

# install by hand, including library files
cd $BUILD/$tarballdir/obj-*
ROOT=$BUILD/root
install -dm 755 $ROOT/tools/signmar/bin
install -m 755 dist/bin/signmar $ROOT/tools/signmar/bin
for lib in $(otool -L dist/bin/signmar | grep @executable_path | sed 's!@executable_path/\([^ ]*\) .*!\1!'); do
	install dist/bin/$lib $ROOT/tools/signmar/bin
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

