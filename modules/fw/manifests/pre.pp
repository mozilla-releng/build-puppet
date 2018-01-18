# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::pre {
    Firewall {
        require => undef,
    }

    # IPv4

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
    # See bug 1401601 and 1409349
    # Just in case the state tables fail to allow a dhcp exchange
    firewall {
        '003 allow dhcp':
            proto  => 'udp',
            sport  => '67',
            dport  => '68',
            action => 'accept';
    }

    # Clean up the IPv6 rules with parenthesis.  Firewall module happily creates but doesn't delete
    # due to improper escaping.
    # See bug 1413305
    exec {
        "clean-ipv6-rules":
            command   => '/sbin/ip6tables -F',
            logoutput => on_failure,
            onlyif    => '/sbin/ip6tables -L | /bin/grep -q "(IPv6)"';
    }->

    # IPv6
    firewall {
        '000 accept related and established flows IPv6':
            proto    => 'all',
            state    => ['RELATED', 'ESTABLISHED'],
            action   => 'accept',
            provider => 'ip6tables';
    }->
    firewall {
        '001 all icmp IPv6':
            proto    => 'icmp',
            action   => 'accept',
            provider => 'ip6tables';
    }->
    firewall {
        '002 local traffic IPv6':
            proto    => 'all',
            iniface  => 'lo',
            action   => 'accept',
            provider => 'ip6tables';
    }

}
