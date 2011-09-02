#! /bin/bash

# first, get some certificates generated and set up.  This uses a deployment-only
# SSH key to re-generate the SSH certificates for this machine.
while ! ssh -i /root/deploykey deployment@puppet > /root/certs.sh; do
    echo "Failed to get certificates"
    sleep 60
done

# source the shell script we got from the deploykey run
cd /var/lib/puppet/ssl || exit 1
. /root/certs.sh

# sanity check
fqdn=`facter fqdn`
if ! [ -e private_keys/$fqdn.pem -a -e certs/$fqdn.pem -a -e certs/ca.pem ]; then
    echo "Got incorrect certificates (!?)"
    find . -type f
    exit 1
fi

while ! /usr/bin/puppet agent; do
    echo "Puppet run failed; re-trying"
    sleep 10
done
