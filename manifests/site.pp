# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import "stages.pp"
import "extlookup.pp"
# both of these should be symlnks to the appropriate organization
import "config.pp"
import "nodes.pp"

# Default to root:root 0644 ownership
File {
    owner => 0,
    group => 0,
    mode => "0644",
    backup => false,
}

# purge unknown users from the system's user database
resources {
    'user':
        purge => true;
}

# similarly, set up the firewall resource, but note that this does not activate
# the firewall
resources {
    'firewall':
        purge => true;
}

# put the default rules before/after any custom rules
Firewall {
    require => Class['fw::pre'],
    before => Class['fw::post'],
}
