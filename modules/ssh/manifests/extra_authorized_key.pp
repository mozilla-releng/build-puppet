# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define ssh::extra_authorized_key($username, $key, $home, $from='', $command='') {
    include ssh::settings

    $authorized_keys = $::operatingsystem ? {
        windows => "${ssh::settings::genkey_dir}/${username}.keys",
        default => "${home}/.ssh/authorized_keys",
    }

    concat::fragment {
        $name:
            target  => $authorized_keys,
            content => template('ssh/extra_authorized_key.erb'),
            notify  => $ssh::settings::notify_on_key_change;
    }
}

