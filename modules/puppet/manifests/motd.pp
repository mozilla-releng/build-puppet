# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Upgrade and configure puppet.  Note that the puppet startup is deferred to
# puppet::atboot and puppet::periodic; the former is used for slaves, while
# other systems run the latter.

class puppet::motd {
    include motd::base

    if ($pin_puppet_env != '') {
        motd {
            'pinned-puppet-env':
                content => "NOTE: puppet environment pinned to '${pin_puppet_env}'\n";
        }
    }
    if ($pin_puppet_server != '') {
        motd {
            'pinned-puppet-server':
                content => "NOTE: puppet server pinned to '${pin_puppet_server}'\n";
        }
    }
}

