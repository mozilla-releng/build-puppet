# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::signmar_sha384 {
    anchor {
        'packages::mozilla::signmar_sha384::begin': ;
        'packages::mozilla::signmar_sha384::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::signmar_sha384::begin'] ->
            package {
                'signmar-sha384':
                    ensure => '53.0a1-1.el6';
            } -> Anchor['packages::mozilla::signmar_sha384::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
