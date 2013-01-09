# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::service {
    case $::operatingsystem {
        CentOS: {
            service {
                "puppetmaster":
                    require => Class["puppetmaster::install"],
                    ensure => stopped,
                    enable => false;
                "httpd":
                    require => Class["puppetmaster::install"],
                    subscribe => [
                        File["/etc/httpd/conf.d/yum_mirrors.conf"],
                        File['/etc/httpd/conf.d/puppetmaster_passenger.conf']
                    ],
                    ensure => running,
                    hasrestart => true,
                    hasstatus =>true,
                    enable => true;
            }
        }

        default: {
            fail("puppetmaster::service support missing for $::operatingsystem")
        }
    }
}
