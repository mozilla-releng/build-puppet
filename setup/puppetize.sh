#! /bin/bash

echo "Puppetize output is in /root/puppetize.log"

exec >/root/puppetize.log 2>&1

hang() {
    echo "${@}"
    while true; do sleep 60; done
}

if ! [ -f /root/deploypass ]; then
    hang "No deploypass found; cannot puppetize"
fi
deploypass=$(</root/deploypass)

# try to get the certs; note that we can't check the SSL cert here, because it
# is self-signed by whatever puppet master we find; the SSL is mainly to
# encipher the password, so this isn't a big problem.
while ! wget -O /root/certs.sh --http-user=deploy --no-check-certificate \
    --http-password=$deploypass https://puppet/deploy/getcert.cgi
do
    echo "Failed to get certificates; re-trying"
    sleep 60
done

# make sure the time is set correctly, or SSL will fail, badly.
ntprunning=`ps ax | grep ntpd | grep -v grep`
[ -n "$ntprunning" ] && /sbin/service ntpd stop
/usr/sbin/ntpdate pool.ntp.org
[ -n "$ntprunning" ] && /sbin/service ntpd start

# source the shell script we got from the deploy run
mkdir -p /var/lib/puppet/ssl/private_keys || exit 1
mkdir -p /var/lib/puppet/ssl/certs || exit 1
cd /var/lib/puppet/ssl || exit 1
. /root/certs.sh

# sanity check
fqdn=`facter fqdn`
if ! [ -e private_keys/$fqdn.pem -a -e certs/$fqdn.pem -a -e certs/ca.pem ]; then
    find . -type f
    hang "Got incorrect certificates (!?)"
fi

date
echo "$fqdn.pem" validity
openssl x509 -text -in certs/$fqdn.pem | grep -A2 Valididty
echo "ca.pem" validity
openssl x509 -text -in certs/ca.pem | grep -A2 Valididty

echo "deleting deploypass"
rm /root/deploypass || exit 1

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
