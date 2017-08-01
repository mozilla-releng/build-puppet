# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define fw::ipchain_rule (

    $log = false,

)
{
    include fw::pre
    include fw::post

    $source     = regsubst($name, '^(\d+\.\d+\.\d+\.\d+/\d+)\s([a-z]*)/([0-9]*)\s(.+)$', '\1')
    $proto      = regsubst($name, '^(\d+\.\d+\.\d+\.\d+/\d+)\s([a-z]*)/([0-9]*)\s(.+)$', '\2')
    $dport      = regsubst($name, '^(\d+\.\d+\.\d+\.\d+/\d+)\s([a-z]*)/([0-9]*)\s(.+)$', '\3')

    # Generate a single ipchains rule
    firewall {
        "200 ${name}":
            proto  => $proto,
            dport  => $dport,
            source => $source,
            action => accept;
    }

    # If $log is true, we add a matching log rule in addition to the actually rule
    if $log {
        firewall {
            "005 ${name}-logging":
                proto  => $proto,
                dport  => $dport,
                source => $source,
                log_prefix => "IPTABLES: ",
                jump   => 'LOG';
        }
    }
}

