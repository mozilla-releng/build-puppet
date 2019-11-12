# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::zstandard {
    case $::operatingsystem {
        Ubuntu: {
            package { 'zstd':
                ensure => installed,
            }

            package { 'python3-pip':
                ensure => installed,
            }

            package { 'python-pip':
                ensure => installed,
            }

            # BUG: on Puppet < 6, this requires two runs to install
            # https://tickets.puppetlabs.com/browse/PUP-7644
            package { 'zstandard':
                ensure   => '0.11.1',
                name     => 'zstandard',
                provider => ['pip', 'pip3'],
                require  => [ Package['python-pip'], Package['python3-pip']]
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
