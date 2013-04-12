# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class httpd {
    include packages::httpd

    case $::operatingsystem {
        Darwin: {
            service {
                'org.apache.httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running ;
            }
        }
        CentOS: {
            service {
                'httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
        }
        Ubuntu: {
            service {
                'apache2' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
            file {
                # Bug 861200. Remove default vhost config
                "/etc/apache2/sites-enabled/000-default":
                    ensure => absent;
            }
        }
        default: {
            fail("Don't know how to set up httpd on $::operatingsystem")
        }
    }
}
