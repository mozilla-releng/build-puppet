# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::bash {

    anchor {
        'packages::bash::begin': ;
        'packages::bash::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemmajrelease {
                6: {
                    realize(Packages::Yumrepo['bash'])
                    package {
                        'bash':
                            ensure => '4.1.2-15.el6_5.2';
                    }
                }
                default: {
                    fail("Unrecognized CentOS version ${::operatingsystemrelease}")
                }
            }
        }
        Darwin: {
            packages::pkgdmg {
                'bash':
                    os_version_specific => false,
                    version             => '3.2-moz3';
            }
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    realize(Packages::Aptrepo['bash'])
                    package {
                        'bash':
                            ensure => '4.2-2ubuntu2.5';
                    }
                }
                14.04: {
                    realize(Packages::Aptrepo['bash'])
                    package {
                        'bash':
                            ensure => '4.3-7ubuntu1.4';
                    }
                }
                16.04: {
                    package {
                        'bash':
                            ensure => '4.3-14ubuntu1';
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }

        Windows: {
            # on Windows, we use the bash that ships with MozillaBuild
            include packages::mozilla::mozilla_build
            Anchor['packages::bash::begin'] ->
            Class['packages::mozilla::mozilla_build']
            -> Anchor['packages::bash::end']
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
