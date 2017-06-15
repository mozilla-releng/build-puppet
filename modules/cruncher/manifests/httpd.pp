# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher::httpd {
    include ::config
    include users::buildduty

    case $::operatingsystem {
        CentOS: {
            # Create RootDir
            file {
                '/var/www/html/builds/':
                    ensure => directory,
                    owner  => $users::buildduty::username,
                    group  => $users::buildduty::group;
            }

            httpd::config {
                'cruncher.conf':
                    content => template('cruncher/cruncher.conf.erb');
            }

            # add a dependency between resources not defined here
            File['/etc/puppet/puppet.conf'] ~> Service['httpd']
            Package['openssl'] ~> Service['httpd']


            # add a dependency between resources not defined here
            #Package['openssl'] ~> Service['httpd']
        }

        default: {
            fail("cruncher::httpd support missing for ${::operatingsystem}")
        }
    }
}
