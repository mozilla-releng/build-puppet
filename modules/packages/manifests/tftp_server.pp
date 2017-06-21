# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::tftp_server {
    include packages::xinetd

    case $::operatingsystem {
        CentOS: {
            package {
                'tftp-server':
                    ensure  => latest,
                    require => Class['packages::xinetd'];
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
