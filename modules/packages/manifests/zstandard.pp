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

            package { 'zstandard-py2':
                ensure   => '0.11.1',
                name     => 'zstandard',
                provider => 'pip',
                require  => Package['python-pip'],
            }

            # BUG: on Puppet < 6, this requires two runs to install 
            # https://tickets.puppetlabs.com/browse/PUP-7644
            package { 'zstandard-py3':
                ensure   => '0.11.1',
                name     => 'zstandard',
                provider => 'pip3',
                require  => Package['python3-pip'],
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
