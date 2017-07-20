# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::puppet {
    anchor {
        'packages::puppet::begin': ;
        'packages::puppet::end': ;
    }

    $puppet_version     = '3.7.0'
    $puppet_dmg_version = $puppet_version
    $puppet_rpm_version = "${puppet_version}-1.el6"
    $puppet_deb_version = "${puppet_version}-1puppetlabs1"
    $facter_version     = '2.2.0'
    $facter_dmg_version = $facter_version
    $facter_rpm_version = "${facter_version}-1.el6"
    $facter_deb_version = "${facter_version}-1puppetlabs1"

    case $::operatingsystem {
        CentOS: {
            package {
                'puppet':
                    ensure => $puppet_rpm_version;
                'facter':
                    ensure => $facter_rpm_version;
            }
        }
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04, 14.04: {
                    package {
                        ['puppet', 'puppet-common']:
                            ensure => $puppet_deb_version;
                        ['facter']:
                            ensure => $facter_deb_version;
                    }
                }
                16.04:  {
                    package {
                        ['puppet', 'puppet-common']:
                            ensure => '3.8.5-2';
                        ['facter']:
                            ensure => '2.4.6-1';
                    }
                }
            }
        }
        Darwin: {
            # These DMGs come directly from http://downloads.puppetlabs.com/mac/
            Anchor['packages::puppet::begin'] ->
            packages::pkgdmg {
                'puppet':
                    os_version_specific => false,
                    version             => $puppet_dmg_version;
                'facter':
                    os_version_specific => false,
                    version             => $facter_dmg_version;
            } -> Anchor['packages::puppet::end']

            # This is built with json_pure-dmg.sh on a Mountain Lion system, as
            # ML's Ruby doesn't include a JSON module.  Lion and Mavericks seem
            # unaffected, but Snow Leopard is affected.  When
            # https://tickets.puppetlabs.com/browse/PUP-2616 is fixed, this
            # should no longer be necessary
            if ($::macosx_productversion_major == '10.8') {
                Anchor['packages::puppet::begin'] ->
                packages::pkgdmg {
                    'json_pure':
                        os_version_specific => true,
                        version             => '1.8.1';
                } -> Anchor['packages::puppet::end']
            }
        }
        Windows: {
            #Puppet installation is currently handled through GPO.
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
