/bin/bash

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

version=1.0-1

# download the corresponding srpm and extract it
url=http://puppetagain.pub.build.mozilla.org/data/repos/yum/releng/public/CentOS/6/noarch/mozilla-signing-test-files-$version.src.rpm

curl -v $url | bsdtar -xf -

# install by hand
ROOT=$BUILD/root
base=$ROOT/tools/signing-test-files
install -dm 755 $base
install test.exe $base
install test.mar $base
install test.tar.gz $base
install test.zip $base

cd $BUILD
mkdir dmg
fullname=signing_test_files-$version
shortname=$(echo $fullname | tr -dc 'a-z0-9')
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
packagemaker -r $ROOT -v -i org.libevent.$shortname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "$fullname" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
