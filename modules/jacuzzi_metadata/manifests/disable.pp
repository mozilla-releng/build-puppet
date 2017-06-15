# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class jacuzzi_metadata::disable {
    file {
        '/etc/init.d/jacuzzi_metadata':
            ensure => absent;
        '/etc/jacuzzi_metadata.json':
            ensure => absent;
        '/usr/local/bin/jacuzzi_metadata.py':
            ensure => absent;
    }
    case $::operatingsystem {
        Ubuntu, CentOS: {
            service {
                'jacuzzi_metadata':
                    ensure => stopped,
                    enable => false;
            }
        }
    }
}
