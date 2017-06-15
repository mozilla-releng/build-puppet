# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class grub {

    case $::operatingsystem {
        'CentOS': {
            # Nothing to do; CentOS isn't broken
        }
        'Ubuntu': {
            case $::operatingsystemrelease {
                '12.04': {
                    # disable submenuis in grub
                    file { '/etc/grub.d/10_linux':
                        ensure => present,
                        mode   => '0755',
                        source => 'puppet:///modules/grub/10_linux';
                    }
                }
                '14.04': {
                    # Do nothing; submenus are disabled in the defaults
                }
                '16.04': {
                    # Do nothing; submenus are disabled in the defaults
                }
                default: {
                    fail("Grub module is not supported on ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("Grub module is not supported on ${::operatingsystem}")
        }
    }

}
