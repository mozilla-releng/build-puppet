#! /bin/bash

set -e

if ! test -f py27_virtualenv.spec; then
    echo "Run this from the root of the unpacked SRPM (it uses the sources)"
    exit 1
fi

# variables to parallel the spec file
realname=virtualenv
pyrealname=python27
pyver=2.7
pyhome=/tools/$pyrealname
python_sitelib=$pyhome/lib/python$pyver/site-packages
_prefix=/tools/$realname
_libdir=$_prefix/lib
package_sitelib=$_libdir/python$pyver/site-packages
version=1.7.1.2
release=1

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
ln -s $_prefix/bin/virtualenv $ROOT/usr/local/bin/virtualenv

# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$pyrealname-$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
/Developer/usr/bin/packagemaker -r $ROOT -v -i com.mozilla.$pyrealname-$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$pyrealname-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
