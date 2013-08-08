#! /bin/bash

set -e

rm -rf build
mkdir -p build
cd build

git clone git://github.com/jhford/screenresolution.git

# prep
cd screenresolution
# check out a version after 1.5 that will hopefully one day be 1.6
VERSION=1.6
git checkout f2c404db62629f504ee56913e59a91470f1d7326

make screenresolution

# The makefile's packaging stuff isn't quite right, so we just replicate it here

PACKAGE_MAKER=/tools/packagemaker/bin/PackageMaker
PREFIX=/usr/local
mkdir -p pkgroot/${PREFIX}/bin
install -s -m 0755 screenresolution \
	pkgroot/${PREFIX}/bin
# compared to the makefile, this omits "--target", so we target the current OS
${PACKAGE_MAKER} --root pkgroot/  --id com.johnhford.screenresolution \
	--out "screenresolution-${VERSION}.pkg" \
	--title "screenresolution ${VERSION}" \
	--version ${VERSION}
rm -f screenresolution.pkg
ln -s screenresolution-${VERSION}.pkg screenresolution.pkg


mkdir -p dmgroot
cp -r screenresolution-${VERSION}.pkg dmgroot/
rm -f screenresolution-${VERSION}.dmg
hdiutil makehybrid -hfs -hfs-volume-name "screenresolution ${VERSION}" \
	-o "screenresolution-${VERSION}.dmg" dmgroot/
echo Result: $PWD/screenresolution-${VERSION}.dmg

