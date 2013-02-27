# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::settings {
    include ::config

    if ($pin_puppet_server != '') {
        $puppet_server = $pin_puppet_server
        $puppet_servers = [ $pin_puppet_server ]
        $use_random_order = false
    } else {
        $puppet_server = $::config::puppet_server
        $puppet_servers = $::config::puppet_servers
        $use_random_order = $::config::use_random_order
    }
}
