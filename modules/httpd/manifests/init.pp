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
                        '/System/Library/LaunchDaemons/org.apache.httpd.plist':
                            source => "puppet:///modules/${module_name}/org.apache.httpd.plist";
                    }
                }
            }
            service {
                'httpd':
                    ensure  => running,
                    name    => 'org.apache.httpd',
                    require => Class['packages::httpd'],
                    enable  => true;
            }
        }
        CentOS: {
            service {
                'httpd' :
                    ensure     => running,
                    name       => 'httpd',
                    require    => Class['packages::httpd'],
                    enable     => true,
                    hasrestart => true,
                    hasstatus  => true,
                    # automatically restart when openssl is upgraded
                    subscribe  => Package['openssl'];
            }
        }
        Ubuntu: {
            service {
                'httpd':
                    ensure  => running,
                    name    => 'apache2',
                    require => Class['packages::httpd'],
                    enable  => true;
            }
            file {
                # Bug 861200. Remove default vhost config
                '/etc/apache2/sites-enabled/000-default':
                    ensure => absent,
                    notify => Service['httpd'];
            }
        }
        Windows: {

        include dirs::slave::talos_data::talos

            # Return set to 1. Installation on the service exits with 1 but installs.
            # The installation dislikes "Order allow,deny" @ line 41 in the conf file
            # However that is a standard configuration
            # This will be followed up in Bug 1270302

            exec {
                'install_apache_service':
                    command     => '"C:\Program Files\Apache Software Foundation\Apache2.2\bin\httpd.exe" -k install',
                    require     => Class[dirs::slave::talos_data::talos],
                    subscribe   => Packages::Pkgmsi['Apache HTTP Server 2.2.22'],
                    returns     => 1,
                    refreshonly => true;
            }
            service {
                'Apache2.2':
                    enable  => true,
                    require => Packages::Pkgmsi['Apache HTTP Server 2.2.22'];
            }
        }
        default: {
            fail("Don't know how to set up httpd on ${::operatingsystem}")
        }
    }
}
