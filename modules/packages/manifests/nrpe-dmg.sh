#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

MOZ_SUFFIX=-moz1

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

set -e

# need to have the user present locally for the 'make install'
dscl="/usr/bin/dscl"
dspath="/var/db/dslocal/nodes/Default/"
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Groups/nagios
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Groups/nagios PrimaryGroupID 290
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios UniqueID 290
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios PrimaryGroupID 290

# install both nrpe and the plugins in the same package
curl -LO http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.14/nrpe-2.14.tar.gz
tar -xvf nrpe-2.14.tar.gz
pushd nrpe-2.14
./configure --prefix=/usr/local --enable-command-args
make
make DESTDIR=$BUILD/installroot install
popd

curl -LO http://www.nagios-plugins.org/download/nagios-plugins-1.4.16.tar.gz
tar -xvf nagios-plugins-1.4.16.tar.gz
pushd nagios-plugins-1.4.16
./configure --prefix=/usr/local
make


make DESTDIR=$BUILD/installroot install
popd

# set up the postinstall script
mkdir $BUILD/scripts
cat <<'EOF' >$BUILD/scripts/postinstall
#!/bin/bash
install_vol="${3}"
dscl="${install_vol}/usr/bin/dscl"
dspath="${install_vol}/var/db/dslocal/nodes/Default/"
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Groups/nagios
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Groups/nagios PrimaryGroupID 290
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios UniqueID 290
"${dscl}" -f "${dspath}" localonly -create /Local/Target/Users/nagios PrimaryGroupID 290
EOF
chmod +x $BUILD/scripts/postinstall

# -- create-dmg.sh, with --scripts added to the packagemaker invocation

PACKAGE_MAKER="/usr/bin/pkgbuild"

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=nrpe-2.14$MOZ_SUFFIX
PACKAGE_SHORTNAME=nrpe214
INSTALLDIR=/usr/

if [[ -z $DIR_TO_PACKAGE || -z $PACKAGE_BASENAME || -z $PACKAGE_SHORTNAME || -z $INSTALLDIR ]]; then
    echo "Usage: $0 dir-to-package package-base-name package-short-name installdir"
    exit 1
fi
if [[ ! -x $PACKAGE_MAKER ]]; then
    echo "Couldn't find pkgbuild"
    exit 1
fi
if [[ ! -d $DIR_TO_PACKAGE ]]; then
    echo "$DIR_TO_PACKAGE doesn't exist or isn't readable"
    exit 1
fi
if [[ -e $PACKAGE_BASENAME.dmg ]]; then
    echo "$PACKAGE_BASENAME.dmg already exists"
    exit 1
fi

DIR_TO_PACKAGE=${DIR_TO_PACKAGE%/}
tmp=`mktemp -d -t magic`

trap "rm -rf $tmp" EXIT

set -x
rsync -av $DIR_TO_PACKAGE $tmp
$PACKAGE_MAKER -r $tmp -i com.mozilla.$PACKAGE_SHORTNAME --scripts $BUILD/scripts --install-location $INSTALLDIR $tmp/$PACKAGE_BASENAME.pkg
rm -rf $tmp/`basename $DIR_TO_PACKAGE`
hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
echo DMG is at $PWD/$PACKAGE_BASENAME.dmg
