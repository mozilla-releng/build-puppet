# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::duo_unix {

    anchor {
        'packages::duo_unix::begin': ;
        'packages::duo_unix::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['duo_unix'])
            Anchor['packages::duo_unix::begin'] ->
            package {
                'duo_unix' :
                    ensure => '1.10.0-0.el6';
            } -> Anchor['packages::duo_unix::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
