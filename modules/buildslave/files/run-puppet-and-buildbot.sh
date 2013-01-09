#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# MOZILLA DEPLOYMENT NOTES
# - This file is distributed to all Linux test slaves by Puppet, and placed at
#   /home/cltbld/run-puppet-and-buildbot.sh
# - It lives in the 'buildslave' puppet module

# this sleep lets NetworkManager get the network running before we get started
sleep 60

tmp=`mktemp`
/usr/sbin/puppetd --onetime --no-daemonize --server $1 --logdest console --logdest syslog --color false &> $tmp
RETVAL=$?
if grep -q "^err:" $tmp
then
    RETVAL=1
fi
while [[ $RETVAL != 0 ]]
do
    sleep 60
    /usr/sbin/puppetd --onetime --no-daemonize --server $1 --logdest console --logdest syslog --color false &> $tmp
    RETVAL=$?
    if grep -q "^err:" $tmp
    then
        RETVAL=1
    fi
done
rm $tmp
su - cltbld -c 'python /usr/local/bin/runslave.py'
