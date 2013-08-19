#! /bin/bash

VERSION="${1}"
if [ -z "$VERSION" ]; then
	echo "USAGE: $0 version"
	exit 1
fi

set -e

rm -rf build
mkdir -p build
cd build

curl http://puppetagain.pub.build.mozilla.org/data/repos/DMGs/screenresolution-$VERSION.tar.gz | tar -zxf -
cd screenresolution-$VERSION

# build
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

