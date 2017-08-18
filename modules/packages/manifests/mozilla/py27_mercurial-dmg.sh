#! /bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

# variables to parallel the spec file
realname=mercurial
pyrealname=python27
pyver=2.7
pyhome=/tools/$pyrealname
python_sitelib=$pyhome/lib/python$pyver/site-packages
_prefix=/tools/${pyrealname}-${realname}
_libdir=$_prefix/lib
package_sitelib=$_libdir/python$pyver/site-packages
version=3.7.3
release=1
srpm_release=1

# ensure the same build environment (you can change this if necessary, just test carefully)

case "$(sw_vers -productVersion)" in
    10.7) ;;  # ?? lost to the sands of time
    10.8) ;;  # ?? lost to the sands of time
    10.9) ;;  # ?? lost to the sands of time
    10.10)
        # This was built with XCode 6.1 command line tools, but that version of XCode no longer
        # supports a way to find its version on the command line.
        ;;
esac

export PATH=`xcode-select -print-path`:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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

PYTHON=/tools/$pyrealname/bin/python$pyver
if ! test -x $PYTHON; then
    echo "$pyrealname ($PYTHON) must be instaled"
    exit 1
fi

# %build
$PYTHON setup.py build

# %install
ROOT=$BUILD/root
$PYTHON setup.py install -O1 --prefix=$_prefix --root=$ROOT --record=INSTALLED_FILES
mkdir -p $ROOT/$python_sitelib
echo $package_sitelib > $ROOT/$python_sitelib/$realname.pth

# add /usr/local/bin links
mkdir -p $ROOT/usr/local/bin
ln -s $_prefix/bin/hg $ROOT/usr/local/bin/hg

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$pyrealname-$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
if test -n "$USE_PACKAGEMAKER"; then
    # XXX pkgbuild not avail on 10.6
    PATH="$PATH:/tools/packagemaker/bin"
    packagemaker --root $ROOT -i com.mozilla.$pyrealname-$realname -o $pkg -l /
else
    pkgbuild -r $ROOT -i com.mozilla.$pyrealname-$realname --install-location / $pkg
fi
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$pyrealname-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
