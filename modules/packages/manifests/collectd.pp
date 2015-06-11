# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::collectd {

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['collectd'])
            package {
                "collectd":
                    ensure => '5.5.0-1.el6';
                "collectd-disk":
                    ensure => '5.5.0-1.el6';
                "libcollectdclient":
                    ensure => '5.5.0-1.el6';
            }
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04, 14.04: {
                    realize(Packages::Aptrepo['collectd'])
                    package {
                        ["collectd-core", "collectd", "libcollectdclient1", "collectd-utils"]:
                            ensure => '5.5.0-1mozilla1';
                    }
                    package {
                        ["libcollectdclient-dev", "collectd-dbg", "collectd-dev"]:
                            ensure => absent;
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version $::operatingsystemrelease")
                }
            }
        }

        Darwin: {
            # This is a dirty workaround to downgrading collectd back to 5.3.0
            # since the pkgdmg provider lacks the ability to do so
            exec { "remove_collectd_5.5.0":
                command => "/bin/rm -rf /var/db/.puppet_pkgdmg_installed_collectd-5.3.0.dmg",
                onlyif  => "/bin/test -f /var/db/.puppet_pkgdmg_installed_collectd-5.5.0.dmg";
            }->
            packages::pkgdmg {
                'collectd':
                    version => '5.3.0',
                    os_version_specific => true,
                    private => false;
            }->
            file { "/var/db/.puppet_pkgdmg_installed_collectd-5.5.0.dmg":
                ensure => absent;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}

