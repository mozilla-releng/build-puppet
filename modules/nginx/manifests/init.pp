# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nginx {
    include packages::nginx

    case $::operatingsystem {
        Ubuntu: {
            service {
                'nginx':
                    ensure     => running,
                    enable     => true,
                    hasrestart => true,
                    hasstatus  => true,
                    require    => Class['packages::nginx'];
            }
            file {
                '/etc/nginx/sites-enabled/default':
                    ensure => absent;
            }
        }
        default: {
            fail("Don't know how to set up nginx on ${::operatingsystem}")
        }
    }
}
