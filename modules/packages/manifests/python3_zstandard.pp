# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python3_zstandard {
    case $::operatingsystem {
        Ubuntu: {
            package { 'python3-pip':
                ensure => installed,
            }

            # BUG: on Puppet < 4, naming collision issue:
            #  https://tickets.puppetlabs.com/browse/PUP-1073
            #  https://tickets.puppetlabs.com/browse/PUP-2313
            #  - can't use package to install zstandard for pip/py2 and pip3/py3

            # BUG: on Puppet < 6, package with pip3 requires two runs to install
            # https://tickets.puppetlabs.com/browse/PUP-7644

            # package { 'zstandard':
            #     ensure   => '0.11.1',
            #     provider => 'pip3',
            #     require  => Package['python3-pip'],
            # }

            exec { 'install zstandard':
                command => '/usr/bin/pip3 install zstandard==0.11.1',
                # TODO: avoid unecessary runs with unless
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
