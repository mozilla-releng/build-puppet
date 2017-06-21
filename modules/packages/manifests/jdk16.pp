# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::jdk16 {

  anchor {
        'packages::jdk16::begin': ;
        'packages::jdk16::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            $osrelease = $::operatingsystemrelease ? {
                6.2 => '1.6.0.0-1.43.1.10.6.el6_2',
                6.5 => '1.6.0.41-1.13.13.1.el6_8'
            }
            package {
                # the precise version here isn't terribly important, at least for signing servers,
                # as long as it's 1.6.
                ['java-1.6.0-openjdk', 'java-1.6.0-openjdk-devel']:
                    ensure => $osrelease;
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }

}
