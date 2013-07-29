#! /bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e
set -x

# within the xcode-4.2 metapackage, a bunch of the components now have expired
# certs.  However, expanding and flattening them has the side-effect of stripping
# the certs.  See http://managingosx.wordpress.com/2012/03/24/fixing-packages-with-expired-signatures/

ORIG_VOL="${1}"
if [ -z "${ORIG_VOL}" ] || [ ! -d "${ORIG_VOL}" ]; then
    echo "pass the path to a mounted version of the original xcode-3.2.6 DMG as the arg to this script"
    exit 1
fi

rm -rf /tmp/repack-xcode
mkdir -p /tmp/repack-xcode/dmg/Packages
cp -r "${ORIG_VOL}"/Xcode.mpkg /tmp/repack-xcode/dmg/Xcode.mpkg

cd /tmp/repack-xcode/dmg/Packages
for pkg in "${ORIG_VOL}/Packages/"*.pkg; do
    base=`basename $pkg`
    rm -rf /tmp/tmp.pkg
    pkgutil --expand $pkg /tmp/tmp.pkg
    pkgutil --flatten /tmp/tmp.pkg /tmp/repack-xcode/dmg/Packages/$base
done

cd /tmp/repack-xcode
dmg=xcode-with-certs-stripped-4.2.dmg
hdiutil makehybrid -hfs -hfs-volume-name "Repacked Xcode with certs stripped" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
