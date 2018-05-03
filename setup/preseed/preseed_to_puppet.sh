#!/bin/bash

set -x

fail() {
    echo "INSTALL FAILED"
    # if we exit, the install will continue.  That's not what we want.  So busyloop.
    while true; do
        sleep 60;
    done
}

# get the PUPPET_PASS; this will be our key to getting a certificate down
# the line..
for word in $(</proc/cmdline); do
        case $word in
                PUPPET_PASS=*)
                    PUPPET_PASS="${word//PUPPET_PASS=}" ;;
        esac
done

# Check that PUPPET_PASS is set
if [ -z "$PUPPET_PASS" ]; then
    echo "PUPPET_PASS was not set; aborting setup."
    fail
fi

# Check that puppet is installed properly
if ! puppet --version >/dev/null; then
    echo "Puppet does not appear to be installed properly."
    fail
fi

# Stop and disable puppet daemon under systemd
systemctl stop puppet || fail
systemctl disable puppet || fail

# fix up /etc/issue
(
    grep -v '^Kickstart' /etc/issue
    echo "Kickstart Date:" `date`
    echo "Kickstart OS:" `facter operatingsystem` `facter operatingsystemrelease`
) > /etc/issue~
mv /etc/issue~ /etc/issue

# install the deploy key
echo "$PUPPET_PASS" > /root/deploypass
chmod 600 /root/deploypass

# set up the puppetize script to run at boot
hgrepo="https://hg.mozilla.org/build/puppet"
# try to use the proxy, falling back to a direct fetch (e.g., if the DC doesn't have a proxy)
https_proxy=https://proxy.dmz.mdc2.mozilla.com:3128/ wget --tries=3 --waitretry=10 -O/root/puppetize.sh "$hgrepo/raw-file/default/modules/puppet/files/puppetize.sh" \
    || https_proxy=https://proxy.dmz.mdc1.mozilla.com:3128/ wget --tries=3 --waitretry=10 -O/root/puppetize.sh "$hgrepo/raw-file/default/modules/puppet/files/puppetize.sh" \
    || wget --tries=6 --waitretry=60 -O/root/puppetize.sh "$hgrepo/raw-file/default/modules/puppet/files/puppetize.sh" \
    || fail
chmod +x /root/puppetize.sh

rc_local="/etc/rc.local"

(
    echo '#!/bin/bash'
    echo 'echo "puppetize output is in puppetize.log"'
    echo '/bin/bash /root/puppetize.sh 2>&1 | tee /root/puppetize.log'
) > ${rc_local}~
mv -f ${rc_local}~ ${rc_local} || fail
chmod +x ${rc_local} || fail


exit 0
