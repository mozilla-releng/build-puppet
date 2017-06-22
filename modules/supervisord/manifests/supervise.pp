# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define supervisord::supervise($command, $user, $autostart=true, $autorestart=true, $environment=[], $extra_config='') {
    include supervisord::base

    file {
        "/etc/supervisord.d/${name}":
            content => template('supervisord/snippet.erb'),
            notify  => Service['supervisord'];
    }
}
