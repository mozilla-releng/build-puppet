# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::unixsock {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:UnixSock
    $plugin_name = 'unixsock'

    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $socketgroup = 'collectd'
            $args = [ 'SocketFile "/var/run/collectd-unixsock"',
                      "SocketGroup ${socketgroup}",
                      'SocketPerms 0770',
                      'DeleteSocket true', ]
        }
        default: {
            fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")
        }
    }

    # members of this group may interact with collectd via the unixsocket
    # if group write permissions are set on the socket file
    group {
        $socketgroup:
            ensure => present,
            system => true;
    }
    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
