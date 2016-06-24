# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class dnsmasq {
    include dnsmasq::settings
    include packages::dnsmasq

    file {
        $dnsmasq::settings::conf:
            ensure  => absent,
            notify  => Service[$dnsmasq::settings::servicename],
            require => Class['packages::dnsmasq'];

        $dnsmasq::settings::confdir:
            ensure  => directory,
            recurse => true,
            purge   => true,
            force   => true,
            notify  => Service[$dnsmasq::settings::servicename],
            require => Class['packages::dnsmasq'];

        $dnsmasq::settings::default:
            ensure  => present,
            notify  => Service[$dnsmasq::settings::servicename],
            require => Class['packages::dnsmasq'];
    }

    service {
        $dnsmasq::settings::servicename:
            ensure     => running,
            enable     => true,
            hasrestart => true,
            hasstatus  => true,
            require    => Class['packages::dnsmasq'];
    }
}
