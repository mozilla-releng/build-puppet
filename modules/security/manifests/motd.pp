# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class security::motd {
    include ::security
    motd {
        'security-level':
            content => "This host is set to follow security level \"${::security::level}\"\n",
            order   => 01;
    }
}
