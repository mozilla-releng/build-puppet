# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::lego {
    realize(Packages::Yumrepo['lego'])
    case $::operatingsystem {
        CentOS: {
            package {
                'lego':
                    ensure => '0.3.1-28ead50ff1ca93acdb62734d3ed8da0206d036ff';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
