# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::libsodium {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['libsodium'])
            package {
                ['libsodium', 'libsodium-devel']:
                    ensure => latest;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
