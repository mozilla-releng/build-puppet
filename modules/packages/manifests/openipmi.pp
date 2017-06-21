# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::openipmi {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.2: {
                    package {
                        'OpenIPMI':
                            ensure => latest;
                        'ipmitool':
                            # 1.8.11-21 requires a newer libcrypto
                            ensure => '1.8.11-12.el6';
                    }
                }
                6.5: {
                    realize(Packages::Yumrepo['openipmi'])
                    package {
                        'OpenIPMI':
                            ensure => latest;
                        'ipmitool':
                            ensure => '1.8.11-21.el6';
                    }
                }
                default: {
                    fail("Unrecognized CentOS version ${::operatingsystemrelease}")
                }
            }
        }
        Ubuntu: {
            package {
                [ 'openipmi',
                  'ipmitool',
                ]:
                    ensure => latest;
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
