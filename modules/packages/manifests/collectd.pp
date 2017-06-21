# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::collectd {

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['collectd'])
            package {
                'collectd':
                    ensure => '5.5.0-1.el6';
                'collectd-disk':
                    ensure => '5.5.0-1.el6';
                'libcollectdclient':
                    ensure => '5.5.0-1.el6';
            }
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04, 14.04: {
                    realize(Packages::Aptrepo['collectd'])
                    package {
                        ['collectd-core', 'collectd', 'libcollectdclient1', 'collectd-utils']:
                            ensure => '5.5.0-1mozilla1';
                    }
                    package {
                        ['libcollectdclient-dev', 'collectd-dbg', 'collectd-dev']:
                            ensure => absent;
                    }
                }
                16.04: {
                    package {
                        ['collectd-core', 'collectd', 'libcollectdclient1', 'collectd-utils']:
                            ensure => '5.5.1-1build2';
                    }
                    package {
                        ['libcollectdclient-dev', 'collectd-dbg', 'collectd-dev']:
                            ensure => absent;
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }

        Darwin: {
            packages::pkgdmg {
                'collectd':
                    version             => '5.5.0-1',
                    os_version_specific => true,
                    private             => false;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

