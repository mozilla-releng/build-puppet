# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define fw::pf_rule (
    $sources,
    $proto,
    $port,
    $log = false
)
{

    include ::pf

    # Create a source table
    pf::table { $name:
        cidr_array => $sources,
    }

    # Create a rule with the source table as the source address
    pf::rule { $name:
        action    => 'pass',
        direction => 'in',
        log       => $log,
        quick     => true,
        interface => 'en0',
        af        => 'inet',
        protocol  => $proto,
        src_addr  => "<${name}>",
        dst_port  => $port,
    }
}
