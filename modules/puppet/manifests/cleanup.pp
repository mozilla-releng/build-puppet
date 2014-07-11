# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::cleanup {
    if ($::operatingsystem == 'CentOS') {
        file {
            ['/var/log/anaconda.log', '/var/log/anaconda.syslog']:
                ensure => absent;
        }
    }
}

