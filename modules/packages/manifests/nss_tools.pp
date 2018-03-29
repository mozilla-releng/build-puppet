# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nss_tools {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['nss'])
            package {
                ['nss', 'nss-sysinit', 'nss-tools']:
                    ensure => '3.27.1-13.el6';

                'nss-util':
                    ensure => '3.27.1-3.el6';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
