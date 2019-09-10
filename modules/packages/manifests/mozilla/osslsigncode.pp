# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::osslsigncode ($version = "1.7.1-2.el6") {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['osslsigncode'])
            package {
                'osslsigncode':
                    ensure => $version;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
