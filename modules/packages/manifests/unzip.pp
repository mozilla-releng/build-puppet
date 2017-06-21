# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::unzip {
    case $::operatingsystem {
        CentOS: {
            package {
                'unzip':
                    ensure => latest;
            }
        }
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        'unzip':
                            ensure => '6.0-4ubuntu1';
                    }
                }
                16.04: {
                    package {
                        'unzip':
                            ensure => '6.0-20ubuntu1';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        Darwin: {
            packages::pkgdmg {
                'unzip':
                    version             => '6.0',
                    os_version_specific => false,
                    private             => false;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
