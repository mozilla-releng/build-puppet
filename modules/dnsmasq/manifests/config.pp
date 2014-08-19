# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define dnsmasq::config($content='', $ensure='present') {
    include dnsmasq
    include dnsmasq::settings
    include packages::dnsmasq

    $conf =  "${dnsmasq::settings::confdir}/${title}"

    if ($ensure == 'absent') {
        file {
            $conf:
                ensure => absent,
                notify => Service[$dnsmasq::settings::servicename];
        }
    } else {
        file {
            $conf:
                ensure  => present,
                content => $content,
                notify  => Service[$dnsmasq::settings::servicename],
                require => Class['packages::dnsmasq'];
        }
    }
}
