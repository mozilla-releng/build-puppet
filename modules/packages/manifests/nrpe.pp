# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nrpe {

    anchor {
        'packages::nrpe::begin': ;
        'packages::nrpe::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04, 14.04: {
                    package {
                        'nagios-nrpe-server':
                            ensure          => latest,
                            install_options => [ '--no-install-recommends' ];
                        'nagios-plugins':
                            ensure          => latest,
                            install_options => [ '--no-install-recommends' ];
                    }
                }
                16.04: {
                    realize(Packages::Aptrepo['nrpe'])
                        Anchor['packages::nrpe::begin'] ->
                        package {
                            'nagios-nrpe-server':
                                ensure          => '3.2.1-1',
                                install_options => [ '--no-install-recommends' ];
                            'nagios-nrpe-plugin':
                                ensure          => '3.2.1-1',
                                install_options => [ '--no-install-recommends' ];
                            'nagios-plugins-extra':
                                ensure          => '2.1.2-2ubuntu2',
                                install_options => [ '--no-install-recommends' ];
                        } -> Anchor['packages::nrpe::end']
                }
                default: {
                    fail ("Cannot install on Ubuntu ${::operatingsystemrelease}")
                }
            }
        }
        CentOS: {
            package {
                'nrpe':
                    ensure => latest;
                'nagios-plugins-nrpe':
                    ensure => latest;
                'nagios-plugins-all':
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                # this DMG contains both nrpe and the plugins, and creates
                # the user/group, but does not install the service.
                'nrpe':
                    version => '2.14-moz1';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
