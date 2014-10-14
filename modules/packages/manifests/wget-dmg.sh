#! /bin/bash

set -e

# variables to parallel the spec file
realname=wget
version=1.12
release=1
srpm_release=1.4

pod2man_broken=false
case "$(sw_vers -productVersion)" in
    10.6) ;;  # ?? lost to the sands of time
    10.7) ;;  # ?? lost to the sands of time
    10.8) ;;  # ?? lost to the sands of time
    10.9) ;;  # ?? lost to the sands of time
    10.10)
        # This was built with XCode 6.1 command line tools, but that version of XCode no longer
        # supports a way to find its version on the command line.

        # pod2man on the Yosemite preview and/or XCode preview doesn't work
        pod2man_broken=true
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

curl -L http://puppetagain.pub.build.mozilla.org/data/repos/yum/releng/public/CentOS/6/noarch/wget-$version-$srpm_release.el6.src.rpm | bsdtar -x
ls

# %prep
tar -zxf $realname-$version.tar.bz2
cd $realname-$version

# patch out the pod2man call
if $pod2man_broken; then
    sed 's/@COMMENT_IF_NO_POD2MAN@/#/' < doc/Makefile.in > doc/Makefile.in~
    mv doc/Makefile.in{~,}
fi

# %build
./configure
make -j2

# %install
ROOT=$BUILD/root
make install DESTDIR=$ROOT
mkdir -p $ROOT/usr/local/bin


# build the package (no RPM equivalent, sorry)
cd $BUILD
mkdir dmg
fullname=$realname-$version-$release
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
pkgbuild  -r $ROOT -i com.mozilla.$realname --install-location / $pkg
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
