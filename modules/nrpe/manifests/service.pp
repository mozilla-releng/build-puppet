# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::service {
    include nrpe::settings

    case $::operatingsystem {
        Ubuntu: {
            include packages::nrpe
            service {
                'nagios-nrpe-server':
                    ensure  => running,
                    enable  => true,
                    require => Class['packages::nrpe'];
            }
        }
        CentOS: {
            include packages::nrpe
            service {
                'nrpe':
                    ensure  => running,
                    enable  => true,
                    require => Class['packages::nrpe'];
            }
        }
        Darwin: {
            include packages::nrpe
            $svc_plist = '/Library/LaunchDaemons/org.nagios.nrpe.plist'
            file {
                $svc_plist:
                    content => template("${module_name}/nrpe.plist.erb");
            }
            service {
                'org.nagios.nrpe':
                    ensure  => running,
                    enable  => true,
                    require => [
                        Class['packages::nrpe'],
                        File[$svc_plist],
                    ];
            }
        }
        Windows: {
            include packages::nsclient_plus_plus
            service {'NSClientpp':
                ensure    => running,
                enable    => true,
                require   => Class[ 'packages::nsclient_plus_plus'],
                subscribe => Concat['c:\program files\nsclient++\nsc.ini'],
            }
        }
        default: {
            fail("Don't know how to enable nrpe on ${::operatingsystem}")
        }
    }
}
