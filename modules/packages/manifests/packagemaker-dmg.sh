#! /bin/bash

set -e

version=4.4
realname=packagemaker44

[ -d "$PACKAGEMAKER_APP" ] || {
        echo 'Set $PACKAGEMAKER_APP to the path to to packageMaker.app, in the root of the unpacked'
        echo 'xcode44auxtools6938114a.dmg (Auxiliary Developer Toosl - Late July 2012)'
        exit 1
}

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

ROOT=$BUILD/root
mkdir -p $ROOT/tools/packagemaker/bin
cp "$PACKAGEMAKER_APP/Contents/MacOS/"* $ROOT/tools/packagemaker/bin
mkdir dmg
fullname=packagemaker-$version
pkg=dmg/$fullname.pkg
dmg=$fullname.dmg
"$PACKAGEMAKER_APP/Contents/MacOS/packagemaker" -r $ROOT -v -i com.mozilla.$realname -o $pkg -l /
hdiutil makehybrid -hfs -hfs-volume-name "$fullname" -o ./$dmg dmg
echo "Result:"
echo $PWD/$dmg
