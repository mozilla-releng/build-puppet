# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::resolvconf {
    case $::operatingsystem {
        Ubuntu: {
            file {
                ['/etc/resolvconf/resolv.conf.d/tail', '/etc/resolvconf/resolv.conf.d/original']:
                    ensure => absent,
                    notify => Exec['resolvconf-update'];
            }
            exec {
                'resolvconf-update':
                    command     => '/sbin/resolvconf -u',
                    refreshonly => true;
            }
        }
        default: {
            notice("Don't know how to tweak resolvconf on ${::operatingsystem}.")
        }
    }
}
