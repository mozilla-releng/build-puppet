# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::config {
    include puppet::settings
    include concat::setup

    $puppet_server = $::puppet::settings::puppet_server
    # copy the node-scope variable locally
    $pinned_env    = $pin_puppet_env
    $conf          = $::puppet::settings::conf

    concat {
        $conf:
            mode => filemode(0644);
    }

    concat::fragment { 'top_conf':
        target  => $conf,
        content => template('puppet/puppet.conf.erb'),
        order   => 01,
    }
}
