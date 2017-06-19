# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define motd($content, $order=10) {
    include motd::base
    include motd::settings

    concat::fragment {
        $name:
            target  => $motd::settings::motd_file,
            content => $content,
            order   => $order;
    }
}
