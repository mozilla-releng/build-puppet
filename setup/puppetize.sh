#! /bin/bash

echo "Puppetize output is in /root/puppetize.log"

exec >/root/puppetize.log 2>&1

if ! [ -f /root/deploykey ]; then
    echo "No deploykey found; cannot puppetize"
fi

# make sure the time is set correctly, or SSL will fail, badly.
ntprunning=`ps ax | grep ntpd | grep -v grep`
[ -n "$ntprunning" ] && /sbin/service ntpd stop
/usr/sbin/ntpdate pool.ntp.org
[ -n "$ntprunning" ] && /sbin/service ntpd start

# first, get some certificates generated and set up.  This uses a deployment-only
# SSH key to re-generate the SSH certificates for this machine.
while ! ssh -i /root/deploykey deployment@puppet > /root/certs.sh; do
    echo "Failed to get certificates"
    sleep 60
done

# source the shell script we got from the deploykey run
mkdir -p /var/lib/puppet/ssl/private_keys || exit 1
mkdir -p /var/lib/puppet/ssl/certs || exit 1
cd /var/lib/puppet/ssl || exit 1
. /root/certs.sh

# sanity check
fqdn=`facter fqdn`
if ! [ -e private_keys/$fqdn.pem -a -e certs/$fqdn.pem -a -e certs/ca.pem ]; then
    echo "Got incorrect certificates (!?)"
    find . -type f
    exit 1
fi

date
echo "$fqdn.pem" validity
openssl x509 -text -in certs/$fqdn.pem | grep -A2 Valididty
echo "ca.pem" validity
openssl x509 -text -in certs/ca.pem | grep -A2 Valididty

echo "deleting deploykey"
rm /root/deploykey || exit 1

while ! /usr/bin/puppet agent --no-daemonize --onetime --server=puppet; do
    echo "Puppet run failed; re-trying"
    sleep 10
done

# don't run puppetize at boot anymore
(
    grep -v puppetize /etc/rc.d/rc.local
) > /etc/rc.d/rc.local~
mv /etc/rc.d/rc.local{~,}

echo "System Installed:" `date` >> /etc/issue
