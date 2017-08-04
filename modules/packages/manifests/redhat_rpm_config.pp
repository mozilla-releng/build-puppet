# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::redhat_rpm_config {
    case $::operatingsystem {
        CentOS: {
            package {
                'redhat-rpm-config':
                    ensure => present;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
