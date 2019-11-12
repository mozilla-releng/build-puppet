# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2_zstandard {
    case $::operatingsystem {
        Ubuntu: {
            package { 'zstd':
                ensure => installed,
            }

            package { 'python-pip':
                ensure => installed,
            }

            # BUG: on Puppet < 5, naming collision issue:
            #  https://projects.puppetlabs.com/issues/1398
            #  - can't use package to install zstandard for pip and pip3

            package { 'zstandard':
                ensure   => '0.11.1',
                provider => 'pip',
                require  => Package['python-pip'],
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
