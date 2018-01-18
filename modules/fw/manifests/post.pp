# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::post {
    Firewall {
        before => undef,
    }

    # Log all ssh connections that end up denied
    firewall {
        "995 log all denied ssh":
            proto      => 'tcp',
            dport      => '22',
            log_prefix => "IPTABLES: DENIED ",
            jump       => 'LOG';
    }

    # We can override the default deny policy by setting the node def $fw_allow_all true
    if $fw_allow_all {
        # Accept, accept, accept
        firewall {
            '999 accept all':
                proto  => 'all',
                action => 'accept',
        }
        firewall {
            '999 accept all IPv6':
                proto    => 'all',
                action   => 'accept',
                provider => 'ip6tables',
        }
    } else {
        # Deny, deny, deny
        firewall {
            '999 drop all':
                proto  => 'all',
                action => 'drop',
        }
        firewall {
            '999 drop all IPv6':
                proto    => 'all',
                action   => 'drop',
                provider => 'ip6tables',
        }
    }
}
