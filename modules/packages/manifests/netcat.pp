# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::netcat {
    case $::operatingsystem {
        Ubuntu: {
            package {
                'netcat':
                    ensure => latest;
            }
        }
        CentOS: {
            package {
                'nc':
                    ensure => latest;
            }
        }
        Darwin: {
            # nc is installed with base install image
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
