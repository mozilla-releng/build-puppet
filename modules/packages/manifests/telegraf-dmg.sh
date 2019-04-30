#!/bin/bash

version=${1:-1.10.2}
url=${2:-https://homebrew.bintray.com/bottles/telegraf-${version}.mojave.bottle.tar.gz}
fullname=telegraf-$version

curl -L -o ${fullname}.tgz $url

confpath=pkgroot/etc/telegraf/telegraf.d
mkdir -p $confpath

binpath=pkgroot/usr/local/bin
mkdir -p $binpath
tar -xvzf ${fullname}.tgz --strip-components=3 -C $binpath */*/bin/telegraf

mkdir -p pkgroot/Library/LaunchDaemons
cat << EOF > pkgroot/Library/LaunchDaemons/com.influxdb.telegraf.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>KeepAlive</key>
    <dict>
      <key>SuccessfulExit</key>
      <false/>
    </dict>
    <key>Label</key>
    <string>com.influxdb.telegraf</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/telegraf</string>
      <string>-config</string>
      <string>/etc/telegraf/telegraf.conf</string>
      <string>-config-directory</string>
      <string>/etc/telegraf/telegraf.d</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>/var</string>
    <key>StandardErrorPath</key>
    <string>/var/log/telegraf.log</string>
    <key>StandardOutPath</key>
    <string>/var/log/telegraf.log</string>
  </dict>
</plist>
EOF

mkdir dmg
pkgbuild --root pkgroot -i com.influxdb.telegraf --install-location / dmg/${fullname}.pkg

hdiutil makehybrid -ov -hfs -hfs-volume-name $fullname -o ./$fullname.dmg dmg
echo DMG is at $PWD/$fullname.dmg


