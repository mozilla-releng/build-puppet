# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nodejs {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04:  {
                    package {
                    # This package is a recompiled version of
                    # https://launchpad.net/~chris-lea/+archive/node.js/+packages
                        'nodejs':
                            ensure => '0.10.21-1chl1~precise1';
                    # and it includes node.1.gz which conflicts with nodejs-legacy,
                    # despite not including /usr/bin/node
                        'nodejs-legacy':
                            ensure => absent,
                            before => Package['nodejs'];
                    }
                    file {
                        '/usr/bin/node':
                            ensure => link,
                            target => '/usr/bin/nodejs';
                    }
                }
                16.04:  {
                    package {
                        'nodejs':
                            ensure => latest;
                        'nodejs-legacy':
                            ensure => absent,
                            before => Package['nodejs'];
                    }
                    file {
                        '/usr/bin/node':
                            ensure => link,
                            target => '/usr/bin/nodejs';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        CentOS, RedHat: {
            case $::operatingsystemmajrelease {
                6: {
                    realize(Packages::Yumrepo['nodesource'])
                    realize(Packages::Yumrepo['devtools-2'])
                    package {
                        'nodejs':
                            ensure => '6.10.0-1nodesource.el6';
                    }
                    package {
                        'mpfr':
                            ensure => latest;
                    }
                    package {
                        'devtoolset-2-gcc-c++':
                            ensure => '4.8.2-15.el6';
                    }
                    package {
                        'devtoolset-2-binutils':
                            ensure => '2.23.52.0.1-10.el6';
                    }
                }
                default: {
                    fail("Cannot install on ${::operatingsystem} version ${::operatingsystemmajrelease}")
                }
            }
        }
        Darwin: {
            packages::pkgdmg {
                'nodejs':
                    version             => '0.10.21',
                    os_version_specific => false,
                    private             => false;
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
