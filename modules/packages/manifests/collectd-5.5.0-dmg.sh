#!/bin/bash
set -e

BUILD=$PWD/build
ROOT=$BUILD/installroot
OUT=dmg

REALNAME=collectd
VER=5.5.0
URL=http://collectd.org/files/collectd-${VER}.tar.gz

# Clean build dir
if [ -d $BUILD ]; then
    rm -rf $BUILD
fi
mkdir $BUILD
cd $BUILD

# Download collectd tar.gz
curl -LO $URL

tar -zxvf collectd-${VER}.tar.gz

# Configure, make and install to ROOT
cd collectd-${VER}
patch -p1 < ../../collectd-cpu_states.patch
./configure --prefix=/usr/local
make
make DESTDIR=$ROOT install
cd ..

# insert the launchd plist file
LAUNCHD_PLIST=org.collectd.collectd.plist
mkdir -p $ROOT/Library/LaunchDaemons
cat <<'EOF' >$ROOT/Library/LaunchDaemons/$LAUNCHD_PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
            <string>org.collectd.collectd</string>
        <key>ProgramArguments</key>
            <array>
            <string>/usr/local/sbin/collectd</string>
            <string>-f</string>
            <string>-C</string>
            <string>/usr/local/etc/collectd.conf</string>
            </array>
        <key>RunAtLoad</key>
            <true/>
        <key>KeepAlive</key>
            <false/>
    </dict>
</plist>
EOF
chmod 0644 $ROOT/Library/LaunchDaemons/$LAUNCHD_PLIST

# Make package
mkdir -p $OUT
FULLNAME=$REALNAME-$VER
PKG=$OUT/$FULLNAME.pkg
DMG=$FULLNAME.dmg
pkgbuild --root $ROOT --identifier org.$REALNAME.$REALNAME --install-location / $PKG
hdiutil makehybrid -hfs -hfs-volume-name "${FULLNAME}" -o ./$DMG $OUT
echo "Result:"
echo $PWD/$DMG
