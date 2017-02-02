#! /bin/bash

set -xe

# variables to parallel the spec file
realname=wget
version=1.15
release=2
srpm_release=2

pod2man_broken=false
case "$(sw_vers -productVersion)" in
    10.6*) 
       USE_PACKAGEMAKER="1";
       DONT_USE_RPM_SOURCES=1
       ;;  # ?? lost to the sands of time
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

if test -n "$DONT_USE_RPM_SOURCES"; then
    echo Expect 'wget-$version.tar.gz' in local dir
    echo Copying $realname-$version.tar.gz into build environment
    cp ../wget-$version.tar.gz ./
else
    curl -L http://puppet/data/repos/yum/releng/public/CentOS/6/noarch/wget-$version-$srpm_release.el6.src.rpm > wget-$version-$srpm_release.el6.src.rpm
    bsdtar -xf wget-$version-$srpm_release.el6.src.rpm
fi
ls

# %prep
tar -zxf $realname-$version.tar.gz
cd $realname-$version

# patch out the pod2man call
if $pod2man_broken; then
    sed 's/@COMMENT_IF_NO_POD2MAN@/#/' < doc/Makefile.in > doc/Makefile.in~
    mv doc/Makefile.in{~,}
fi

# %build
./configure  --with-ssl=openssl --enable-largefile --enable-opie --enable-digest --disable-ntlm --enable-nls --enable-ipv6 --disable-rpath
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
if test -n "$USE_PACKAGEMAKER"; then
    # XXX pkgbuild not avail on 10.6
    PATH="$PATH:/tools/packagemaker/bin:/Developer/usr/bin"
    packagemaker --root $ROOT -i com.mozilla.$realname -o $pkg -l /
else
    pkgbuild -r $ROOT -i com.mozilla.$realname --install-location / $pkg
fi
hdiutil makehybrid -hfs -hfs-volume-name "mozilla-$realname-$version-$release" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
