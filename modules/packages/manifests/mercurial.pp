# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mercurial {
    case $::operatingsystem {
        CentOS: {
            package {
                'mercurial':
                    ensure => '1.4-3.el6';
            }
        }
        Ubuntu: {
            package {
                ['mercurial', 'mercurial-common']:
                    ensure => '2.5.4-0mozilla1';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
