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
                'signmar':
                    # 19.0 is what was installed on the old systems
                    ensure => '19.0-2.el6';
            } -> Anchor['packages::mozilla::signmar::end']
        }
        Darwin: {
            Anchor['packages::mozilla::signmar::begin'] ->
            packages::pkgdmg {
                'signmar':
                    # the old systems had 14.0 or something like that,
                    # which we couldn't build.  19.0 didn't work, but
                    # 23.0 did.
                    version => '23.0';
            } -> Anchor['packages::mozilla::signmar::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
