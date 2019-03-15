#! /bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Usage: ./python-bugzilla-dmg python, or ./python-bugzilla-dmg python3
set -e

relname=python-bugzilla
ver=2.2
rel=0
release=1
pythontool=$1
packagename=$pythontool-bugzilla

# ensure the same build environment (you can change this if necessary, just test carefully)

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

ROOT=$BUILD/root

# certifi
curl -o certifi-2018.11.29.tar.gz https://files.pythonhosted.org/packages/55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed/certifi-2018.11.29.tar.gz
tar zxvf certifi-2018.11.29.tar.gz
cd certifi-2018.11.29
$pythontool setup.py install --root $ROOT
cd ..

# Urllib3

curl -o urllib3-1.24.1.tar.gz https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz
tar zxvf urllib3-1.24.1.tar.gz
cd urllib3-1.24.1
$pythontool setup.py install --root $ROOT
cd ..

# idna
curl -o idna-2.8.tar.gz https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz
tar zxvf idna-2.8.tar.gz
cd idna-2.8
$pythontool setup.py install --root $ROOT
cd ..

# chardet

curl -o chardet-3.0.4.tar.gz https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz
tar zxvf chardet-3.0.4.tar.gz
cd chardet-3.0.4
$pythontool setup.py install --root $ROOT
cd ..


# Download requests
curl -o requests-2.21.0.tar.gz https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz#sha256=502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e

tar zxvf requests-2.21.0.tar.gz
cd requests-2.21.0
$pythontool setup.py install --root $ROOT
cd ..

curl -o $relname-$ver.$rel.tar.gz https://files.pythonhosted.org/packages/70/dc/470c8a5693e46ca9deadecbac9eff5a6c04877add84d63d6ae7927ce9580/$relname-$ver.$rel.tar.gz

# %prep
tar -zxvf $relname-$ver.$rel.tar.gz
cd $relname-$ver.$rel


# %install
$pythontool setup.py install --root $ROOT

cd $BUILD
mkdir dmg
fullname=$packagename-$ver.$rel-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/usr/bin/pkgbuild -r $ROOT -i com.mozilla.$relname --install-location / $pkg
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-xz-$ver.$rel-$release" -o ../$dmg dmg
echo "Result:"
echo ../$dmg
