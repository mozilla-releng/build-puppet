# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python26 {
    $python = '/tools/python26/bin/python2.6'
    anchor {
        'packages::mozilla::python26::begin': ;
        'packages::mozilla::python26::end': ;
    }

    Anchor['packages::mozilla::python26::begin'] ->
    case $::operatingsystem {
        CentOS: {
            package {
                'mozilla-python26':
                    ensure => '2.6.7-5.el6';
            }
        }
        Darwin: {
            packages::pkgdmg {
                'python26':
                    version => '2.6.7-1';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    } -> Anchor['packages::mozilla::python26::end']
}
