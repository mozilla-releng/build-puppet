# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::unixsock {
    include collectd
    include collectd::settings

    $enabled_per_os = ['CentOS', 'Ubuntu']

    if $::operatingsystem in $enabled_per_os and $collectd::settings::collectd_enabled {

        $socketfile = $::operatingsystem ? {
            /(CentOS|Ubuntu)/ => '/var/run/collectd-unixsock',
            default           => '/tmp/collectd-unixsock',
        }
        $socketgroup = $::operatingsystem ? {
            /(CentOS|Ubuntu)/ => 'collectd',
            default           => 'root',
        }
        $socketperms = $::operatingsystem ? {
            /(CentOS|Ubuntu)/ => '0770',
            default           => '0770',
        }
        $deletesocket = $::operatingsystem ? {
            /(CentOS|Ubuntu)/ => 'true',
            default           => 'false',
        }

        # members of this group may interact with collectd via the unixsocket
        # if group write permissions are set on the socket file
        group {
            $socketgroup:
                ensure => present,
                system => true;
        }

        file {
            "${collectd::settings::plugindir}/unixsock.conf":
                ensure  => present,
                mode    => '0755',
                notify  => Service['collectd'],
                content => template('collectd/collectd.d/unixsock.conf.erb');
        }
    }
}        
