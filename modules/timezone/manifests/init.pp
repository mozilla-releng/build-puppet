# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class timezone {
    include users::root
    include packages::tzdata

    case $::operatingsystem {
        CentOS: {
            file {
                "/etc/localtime":
                    mode => 644,
                    owner => root,
                    group => $users::root::group,
                    content => file("/usr/share/zoneinfo/US/Pacific"),
                    force => true,
                    require => Class['packages::tzdata'],
                    notify => Exec['/usr/sbin/tzdata-update'];
                "/etc/sysconfig/clock":
                    mode => 644,
                    owner => root,
                    group => $users::root::group,
                    content => 'ZONE="US/Pacific"',
                    force => true,
                    require => Class['packages::tzdata'],
                    notify => Exec['/usr/sbin/tzdata-update'];
            }
            exec {
                "/usr/sbin/tzdata-update":
                    refreshonly => true;
            }
        }
        Ubuntu: {
            file {
                "/etc/timezone":
                    mode => 644,
                    owner => root,
                    group => $users::root::group,
                    content => "America/Los_Angeles\n",
                    force => true,
                    require => Class['packages::tzdata'];
            }
            exec {
                "dpkg-reconfigure-tzdata":
                    command     => "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata",
                    subscribe   => File["/etc/timezone"],
                    refreshonly => true;
            }
        }
        Darwin: {
            osxutils::systemsetup {
                timezone:
                    setting => "America/Los_Angeles";
            }
        }
    }
}
