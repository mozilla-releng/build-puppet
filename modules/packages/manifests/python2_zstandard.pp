# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2_zstandard {
    case $::operatingsystem {
        Ubuntu: {
            package { 'python-pip':
                ensure => installed,
            }

            # BUG: on Puppet < 4, naming collision issue:
            #  https://tickets.puppetlabs.com/browse/PUP-1073
            #  - can't use package to install zstandard for pip and pip3

            # BUG: on Puppet < 6, package with pip3 requires two runs to install
            # https://tickets.puppetlabs.com/browse/PUP-7644

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
