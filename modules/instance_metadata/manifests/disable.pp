# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class instance_metadata::disable {
    file {
        '/etc/init.d/instance_metadata':
            ensure => absent;
        '/etc/instance_metadata.json':
            ensure => absent;
        '/usr/local/bin/instance_metadata.py':
            ensure => absent;
    }
    service {
        'instance_metadata':
            ensure => stopped,
            enable => false;
    }
}
