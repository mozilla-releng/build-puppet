# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class roller::base {

    include docker_ce
    include ::config

    motd {
        'roller':
            content => "The following roller instances are hosted here:\n",
            order   => 90;
    }
}
