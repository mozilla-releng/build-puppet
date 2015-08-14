# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class httpd {
    include packages::httpd
    include packages::openssl

    # note that all of these create a service named 'httpd' - this is part of
    # the external interface of this module

    case $::operatingsystem {
        Darwin: {
            case $::macosx_productversion_major {
                '10.7': {
                    # 10.7 *server* includes a whole mess of stuff we don't want, so we
                    # install a plist that doesn't specify -D MACOSXSERVER.
                    file {
                        "/System/Library/LaunchDaemons/org.apache.httpd.plist":
                            source => "puppet:///modules/${module_name}/org.apache.httpd.plist";
                    }
                }
            }
            service {
                'httpd':
                    name => 'org.apache.httpd',
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running ;
            }
        }
        CentOS: {
            service {
                'httpd' :
                    name => 'httpd',
                    require => Class["packages::httpd"],
                    enable => true,
                    hasrestart => true,
                    hasstatus =>true,
                    ensure => running,
                    # automatically restart when openssl is upgraded
                    subscribe => Package['openssl'];
            }
        }
        Ubuntu: {
            service {
                'httpd':
                    name => 'apache2',
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
            file {
                # Bug 861200. Remove default vhost config
                "/etc/apache2/sites-enabled/000-default":
                    notify => Service["httpd"],
                    ensure => absent;
            }
        }
        default: {
            fail("Don't know how to set up httpd on $::operatingsystem")
        }
    }
}
