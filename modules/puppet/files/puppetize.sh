#! /bin/bash

REBOOT_FLAG_FILE="/REBOOT_AFTER_PUPPET"
[ -f /root/deploypass ] && interactive=false || interactive=true

set -x

hang() {
    echo "${@}"
    while true; do sleep 60; done
}

if ! $interactive; then
    echo "Puppetize output is in /root/puppetize.log"
    exec >/root/puppetize.log 2>&1
fi

fqdn=`facter fqdn`

if [ -f /root/deploypass ]; then
    deploypass=$(</root/deploypass)
    password_option="--http-password=$deploypass"
else
    $interactive || hang "No /root/deploypass and not connected to a tty"
    password_option="--ask-password"
fi

# set up and clean up
mkdir -p /var/lib/puppet/ssl/private_keys || exit 1
mkdir -p /var/lib/puppet/ssl/certs || exit 1
rm -f /var/lib/puppet/ssl/private_keys/$fqdn.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/$fqdn.pem || exit 1
rm -f /var/lib/puppet/ssl/certs/ca.pem || exit 1

# try to get the certs; note that we can't check the SSL cert here, because it
# is self-signed by whatever puppet master we find; the SSL is mainly to
# encipher the password, so this isn't a big problem.
while ! wget -O /root/certs.sh --http-user=deploy --no-check-certificate \
    $password_option https://puppet/deploy/getcert.cgi
do
    echo "Failed to get certificates; re-trying"
    $interactive || sleep 60
done

# make sure the time is set correctly, or SSL will fail, badly.
ntprunning=`ps ax | grep ntpd | grep -v grep`
[ -n "$ntprunning" ] && /sbin/service ntpd stop
/usr/sbin/ntpdate pool.ntp.org
[ -n "$ntprunning" ] && /sbin/service ntpd start

# source the shell script we got from the deploy run
cd /var/lib/puppet/ssl || exit 1
. /root/certs.sh

# sanity check
if ! [ -e private_keys/$fqdn.pem -a -e certs/$fqdn.pem -a -e certs/ca.pem ]; then
    find . -type f
    hang "Got incorrect certificates (!?)"
fi

if ! $interactive; then
    echo "shredding deploypass"
    if test -f /root/deploypass; then
        shred -u -n 7 -z /root/deploypass || exit 1
    fi
fi

if $interactive; then
    echo "Certificates are ready; run puppet now."
    exit 0
fi

rm -f "$REBOOT_FLAG_FILE"

while ! FACTER_PUPPETIZING=true /usr/bin/puppet agent --no-daemonize --onetime --server=puppet --pluginsync; do
    echo "Puppet run failed; re-trying"
    sleep 600
done

# don't run puppetize at boot anymore
(
    grep -v puppetize /etc/rc.d/rc.local
) > /etc/rc.d/rc.local~
mv /etc/rc.d/rc.local{~,}

echo "System Installed:" `date` >> /etc/issue

if [ -f "$REBOOT_FLAG_FILE" ]; then
    rm -f "$REBOOT_FLAG_FILE"
    echo "Rebooting as requested"
    sleep 10
    reboot
fi
