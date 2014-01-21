# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ntp::daemon {
    include ::shared
    include packages::ntp
    include config
    include users::root
    include ntp::atboot

    $ntpserver = $config::ntp_server
    case $::operatingsystem {
        CentOS, Ubuntu: {
            file {
                "/etc/ntp.conf" :
                    content => template("ntp/ntp.conf.erb"),
                    mode => 644,
                    owner => root,
                    group => $users::root::group;
            }
            $service = $operatingsystem ? { CentOS => 'ntpd', Ubuntu => 'ntp' }
            service {
                $service:
                    subscribe => File["/etc/ntp.conf"],
                    enable => true,
                    hasstatus => true,
                    ensure => running;
            }
        }
        Darwin: {
            exec {
                "set-time-server" :
                command => "/usr/sbin/systemsetup -setnetworktimeserver ${ntpserver}",
                refreshonly => true;
            }
            file {
                "$vardir/.puppet-ntpserver" :
                    content => $ntpserver,
                    notify => Exec["set-time-server"];
            }
        }
    }
}
