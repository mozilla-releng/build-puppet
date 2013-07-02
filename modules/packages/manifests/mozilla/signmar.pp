# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::signmar {
    anchor {
        'packages::mozilla::signmar::begin': ;
        'packages::mozilla::signmar::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::signmar::begin'] ->
            package {
                "signmar":
                    ensure => '19.0-2.el6';
            } -> Anchor['packages::mozilla::signmar::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
