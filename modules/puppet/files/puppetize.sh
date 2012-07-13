#! /bin/bash

FQDN=`facter fqdn`
REBOOT_FLAG_FILE="/REBOOT_AFTER_PUPPET"
if [ `facter operatingsystem` = Darwin ]; then
    OS=Darwin
    ROOT=/var/root
else
    OS=Linux
    ROOT=/root
fi

# determine interactivity based on the presence of a deploypass file
[ -f $ROOT/deploypass ] && interactive=false || interactive=true

set -x

hang() {
    echo "${@}"
    while true; do sleep 60; done
}

if ! $interactive; then
    echo "Puppetize output is in $ROOT/puppetize.log"
    exec >$ROOT/puppetize.log 2>&1
fi

if [ -f $ROOT/deploypass ]; then
    deploypass=$(<$ROOT/deploypass)
else
    $interactive || hang "No $ROOT/deploypass and not connected to a tty"
fi

# set up and clean up
mkdir -p /var/lib/puppet/ssl/private_keys || exit 1
mkdir -p /var/lib/puppet/ssl/certs || exit 1
rm -f /var/lib/puppet/ssl/private_keys/$FQDN.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/$FQDN.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/ca.pem || exit 1

# try to get the certs; note that we can't check the SSL cert here, because it
# is self-signed by whatever puppet master we find; the SSL is mainly to
# encipher the password, so this isn't a big problem.  We do this in Python since
# curl and wget are not installed everywhere by default.
while true; do
    python <<EOF
import urllib2, getpass
deploypass="$deploypass"
if not deploypass:
    deploypass = getpass.getpass('deploypass: ')
password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
password_mgr.add_password(None, 'https://puppet', 'deploy', deploypass)
handler = urllib2.HTTPBasicAuthHandler(password_mgr)
opener = urllib2.build_opener(handler)
data = opener.open('https://puppet/deploy/getcert.cgi').read()
open("$ROOT/certs.sh", "w").write(data)
EOF
    if [ $? -ne 0 ]; then
        $interactive && exit 1
        echo "Failed to get certificates; re-trying after delay"
        sleep 60
    else
        break
    fi
done

# make sure the time is set correctly, or SSL will fail, badly.
if [ $OS = "Darwin" ]; then
    if launchctl list org.ntp.ntpd > /dev/null 2>&1 ; then
        launchctl unload /System/Library/LaunchDaemons/org.ntp.ntpd.plist
    fi
    ntpdate pool.ntp.org
    launchctl load -w /System/Library/LaunchDaemons/org.ntp.ntpd.plist
else
    ntprunning=`ps ax | grep ntpd | grep -v grep`
    [ -n "$ntprunning" ] && /sbin/service ntpd stop
    /usr/sbin/ntpdate pool.ntp.org
    [ -n "$ntprunning" ] && /sbin/service ntpd start
fi

# source the shell script we got from the deploy run
cd /var/lib/puppet/ssl || exit 1
. $ROOT/certs.sh

# sanity check
if ! [ -e private_keys/$FQDN.pem -a -e certs/$FQDN.pem -a -e certs/ca.pem ]; then
    find . -type f
    hang "Got incorrect certificates (!?)"
fi

if ! $interactive; then
    if test -f $ROOT/deploypass; then
        echo "securely removing deploypass"
        if [ $OS = "Linux" ]; then
            shred -u -n 7 -z $ROOT/deploypass || hang
        else
            srm -zmf $ROOT/deploypass || hang
        fi
    fi
fi

if $interactive; then
    echo "Certificates are ready; run puppet now."
    exit 0
fi

rm -f "$REBOOT_FLAG_FILE"

# this includes:
# --server=puppet just because (it's the default anyway)
# --pluginsync so that we download plugins on the first run, as they may be required
# --ssldir=/var/lib/puppet/ssl because it defaults to /etc/puppet/ssl on OS X
# FACTER_PUPPETIZING so that the manifests know this is a first run of puppet
while ! FACTER_PUPPETIZING=true /usr/bin/puppet agent --no-daemonize --onetime --server=puppet --pluginsync --ssldir=/var/lib/puppet/ssl; do
    echo "Puppet run failed; re-trying after 10m"
    sleep 600
done

# don't run puppetize at boot anymore (nothing to do on Darwin)
if [ $OS = Linux ]; then
    (
        grep -v puppetize /etc/rc.d/rc.local
    ) > /etc/rc.d/rc.local~
    mv /etc/rc.d/rc.local{~,}
fi

# record the installation date (note that this won't appear anywhere on Darwin)
echo "System Installed:" `date` >> /etc/issue

if [ -f "$REBOOT_FLAG_FILE" ]; then
    rm -f "$REBOOT_FLAG_FILE"
    echo "Rebooting as requested"
    sleep 10
    reboot
fi
