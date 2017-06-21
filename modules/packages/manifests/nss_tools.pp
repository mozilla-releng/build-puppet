# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nss_tools {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['nss'])
            package {
                ['nss', 'nss-sysinit', 'nss-tools']:
                    ensure => '3.21.3-2.el6_8';

                "nss-util":
                    ensure => '3.21.3-1.el6_8';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
