# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::pre {
    Firewall {
        require => undef,
    }

    # Allow a few things globally
    firewall {
        '000 accept related and established flows':
            proto  => 'all',
            state  => ['RELATED', 'ESTABLISHED'],
            action => 'accept',
    }->
    firewall {
        '001 all icmp':
            proto  => 'icmp',
            action => 'accept';
    }->
    firewall {
        '002 local traffic':
            proto   => 'all',
            iniface => 'lo',
            action  => 'accept';
    }->
    firewall {
        '010 ssh for management':
            proto  => 'tcp',
            dport  => 22,
            action => 'accept';
    }->
    firewall {
        '010 nrpe for monitoring':
            # note that NRPE does its own source-IP filtering
            proto  => 'tcp',
            dport  => 5666,
            action => 'accept';
    }
}
