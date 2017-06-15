# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class dnsmasq::settings {

    case $::operatingsystem {
        'Ubuntu': {
            $servicename      = 'dnsmasq'
            $confdir          = '/etc/dnsmasq.d'
            $default          = '/etc/default/dnsmasq'
            $conf             = '/etc/dnsmasq.conf'
        }
        default: {
            fail("${title} is not supported in ${::operatingsystem}")
        }
    }

}
