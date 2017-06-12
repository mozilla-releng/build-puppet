# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class timezone {
    include users::root

    case $::operatingsystem {
        CentOS: {
            include packages::tzdata
            # UTC or US/Pacific
            if ($timezone != 'UTC') {
                $timezone = 'US/Pacific'
            }
            file {
                '/etc/localtime':
                    mode    => '0644',
                    owner   => root,
                    group   => $users::root::group,
                    content => file("/usr/share/zoneinfo/${timezone}"),
                    force   => true,
                    require => Class['packages::tzdata'],
                    notify  => Exec['/usr/sbin/tzdata-update'];
                '/etc/sysconfig/clock':
                    mode    => '0644',
                    owner   => root,
                    group   => $users::root::group,
                    content => "ZONE=\'${timezone}\'",
                    force   => true,
                    require => Class['packages::tzdata'],
                    notify  => Exec['/usr/sbin/tzdata-update'];
            }
            exec {
                '/usr/sbin/tzdata-update':
                    refreshonly => true;
            }
        }
        Ubuntu: {
            include packages::tzdata
            file {
                '/etc/timezone':
                    mode    => '0644',
                    owner   => root,
                    group   => $users::root::group,
                    content => "America/Los_Angeles\n",
                    force   => true,
                    require => Class['packages::tzdata'];
            }
            exec {
                'dpkg-reconfigure-tzdata':
                    command     => '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata',
                    subscribe   => File['/etc/timezone'],
                    refreshonly => true;
            }
        }
        Darwin: {
            # GMT or America/Los_Angeles
            if ($timezone != 'GMT') {
                $timezone = 'America/Los_Angeles'
            }
            osxutils::systemsetup {
                'timezone':
                    setting => $timezone;
            }
        }
        Windows: {
            exec { 'settimezone':
                command => 'tzutil /s "Pacific Standard Time"',
                path    => 'C:/Windows/System32';
            }
        }
    }
}
