#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# You can set PUPPET_SERVER before running this script to use a server other
# than 'puppet'

PUPPET_DIR=/var/lib/puppet

bail() {
    local REASON=$1
    echo "$(date) ${REASON}"
    logger -t "renew-cert-failed" "${REASON}"
    exit 1
}

# This only runs if deploypass exists and puppet is not running
if [ -f $PUPPET_DIR/deploypass -a ! -f $PUPPET_DIR/state/agent_catalog_run.lock ]; then
    deploypass=$(<$PUPPET_DIR/deploypass)
else
    # quietly exit
    exit 1
fi

exec >$PUPPET_DIR/renew_agent_cert.log 2>&1

FQDN=`facter fqdn`
if [ -z $FQDN ]; then
    bail "Failed to determine FQDN; exiting"
fi

OS=`facter operatingsystem`

# make sure the time is set correctly, or SSL will fail, badly.
case "$OS" in
    Darwin)
        if launchctl list org.ntp.ntpd > /dev/null 2>&1 ; then
            launchctl unload /System/Library/LaunchDaemons/org.ntp.ntpd.plist
        fi
        ntpdate pool.ntp.org
        launchctl load -w /System/Library/LaunchDaemons/org.ntp.ntpd.plist
        ;;
    CentOS)
        ntprunning=`ps ax | grep ntpd | grep -v grep`
        [ -n "$ntprunning" ] && /sbin/service ntpd stop
        /usr/sbin/ntpdate pool.ntp.org
        [ -n "$ntprunning" ] && /sbin/service ntpd start
        ;;
    Ubuntu)
        # no ntp service to worry about
        /usr/sbin/ntpdate pool.ntp.org
        ;;
esac

https_proxy= python <<EOF
import urllib2, getpass, ssl
deploypass="""$deploypass"""
puppet_server="${PUPPET_SERVER:-puppet}"
print "Contacting puppet server %s" % (puppet_server,)
password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
password_mgr.add_password(None, 'https://'+puppet_server, 'deploy', deploypass)
handlers = [urllib2.HTTPBasicAuthHandler(password_mgr)]
try:
    # on Pythons that support it, add an SSL context
    context = ssl._create_unverified_context()
    sslhandler = urllib2.HTTPSHandler(context=context)
    handlers.insert(0, sslhandler)
except AttributeError:
    pass
opener = urllib2.build_opener(*handlers)
data = opener.open('https://%s/deploy/getcert.cgi' % (puppet_server,)).read()
open("${PUPPET_DIR}/certs.sh", "w").write(data)
EOF

if [ $? -ne 0 ]; then
    bail "Failed to get certificates; exiting"
fi

# Ensure certs.sh is not empty
if ! [[ -s ${PUPPET_DIR}/certs.sh ]]; then
    bail "${PUPPET_DIR}/certs.sh is empty; exiting"
fi

# set up and clean up
mkdir -p /var/lib/puppet/ssl/private_keys || exit 1
mkdir -p /var/lib/puppet/ssl/certs || exit 1
rm -f /var/lib/puppet/ssl/private_keys/$FQDN.pem || exit 1
rm -f /var/lib/puppet/ssl/public_keys/$FQDN.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/$FQDN.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/ca.pem || exit 1

# source the shell script we got from the deploy run
cd /var/lib/puppet/ssl || exit 1
echo "Sourcing ${PUPPET_DIR}/certs.sh"
. $PUPPET_DIR/certs.sh
rm $PUPPET_DIR/certs.sh

# sanity check
if ! [ -e private_keys/$FQDN.pem -a -e certs/$FQDN.pem -a -e certs/ca.pem ]; then
    find . -type f
    bail "Got incorrect certificates (!?); exiting"
fi

cd /

echo "Securely removing ${PUPPET_DIR}/deploypass"
case "$OS" in
    CentOS)
        shred -u -n 7 -z $PUPPET_DIR/deploypass || exit 1
    ;;
    Ubuntu)
        shred -u -n 7 -z $PUPPET_DIR/deploypass || exit 1
    ;;
    Darwin)
        srm -zmf $PUPPET_DIR/deploypass || exit 1
    ;;
    *)
        rm -rf $PUPPET_DIR/deploypass || exit 1
    ;;
esac

echo "Certificates are ready!"
SUCCESS="New puppet agent certificate installed on ${FQDN} issued from ${PUPPET_SERVER}"
echo $SUCCESS
logger -t "renew-cert-success" $SUCCESS
exit 0

