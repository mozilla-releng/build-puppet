# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define ssh::extra_authorized_key($key, $home, $from='', $command='') {
    concat::fragment {
        "${name}":
            target => "${home}/.ssh/authorized_keys",
            content => template("ssh/extra_authorized_key.erb");
    }
}

