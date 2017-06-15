# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define fw::port {
    $proto = regsubst($name, '^([a-z]*)/([0-9]*)$', '\1')
    $port  = regsubst($name, '^([a-z]*)/([0-9]*)$', '\2')

    firewall {
        "200 ${name}":
            proto  => $proto,
            dport  => $port,
            action => accept;
    }
}
