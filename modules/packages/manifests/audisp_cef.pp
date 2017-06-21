# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::audisp_cef {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['auditd'])
            package {
                'audisp-cef':
                    ensure => '1.3-1';
            }
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}


