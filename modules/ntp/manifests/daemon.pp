# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ntp::daemon {
    include ::shared
    include packages::ntp
    include config
    include users::root

    $ntpservers = $config::ntp_servers
    case $::operatingsystem {
        CentOS, Ubuntu: {
            include ntp::atboot
            file {
                '/etc/ntp.conf' :
                    content => template('ntp/ntp.conf.erb'),
                    mode    => '0644',
                    owner   => root,
                    group   => $users::root::group;
            }
            $service = $::operatingsystem ? { CentOS => 'ntpd', Ubuntu => 'ntp' }
            service {
                $service:
                    ensure    => running,
                    subscribe => File['/etc/ntp.conf'],
                    enable    => true,
                    hasstatus => true;
            }
        }
        Darwin: {
            include ntp::atboot
            file {
                '/etc/ntp.conf' :
                    content => template('ntp/ntp-darwin.conf.erb'),
                    mode    => '0644',
                    owner   => root,
                    group   => $users::root::group;
            }
            service {
                'org.ntp.ntpd':
                    ensure    => running,
                    subscribe => File['/etc/ntp.conf'],
                    enable    => true;
            }
            # OS X Mavericks' NTP support is broken:
            #  - http://www.atmythoughts.com/living-in-a-tech-family-blog/2014/2/28/what-time-is-it
            # The easy solution here is just to restart ntpd periodically in a
            # crontask.  This has the effect of resetting the time
            # periodically, but it's the closest that we can get.  This *may*
            # leave ntp.drift accurate enough that pacemaker can avoid totally
            # messing the time up between cron runs, but that remains to be
            # seen.
            cron {
                'whack-apple-ntpd':
                    command => '/usr/bin/killall ntpd',
                    minute  => 0;
            }
        }
        Windows: {
            class { 'ntp::w32time':
                daemon => true,
            }
        }
    }
}
