# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define fw::ipchain_rule (

    $proto,
    $dport,
    $log = false,

)
{
    include fw::pre
    include fw::post

    $source = regsubst($name, '^(\d+\.\d+\.\d+\.\d+/\d+)\s(.+)$', '\1')

    # Generate a single iptable rule
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
                proto      => $proto,
                dport      => $dport,
                source     => $source,
                log_prefix => "IPTABLES: ",
                jump       => 'LOG';
        }
    }
}

