# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::iptables {
    # This class disables unnecessary services on the slave

    case $::operatingsystem {
        CentOS: {
            service { ['iptables','ip6tables']:
                ensure => stopped,
                enable => false,
            }
        }
    }
}
