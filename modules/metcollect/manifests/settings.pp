# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class metcollect::settings {
    include ::config

    $exe_path = "C:\\Program Files (x86)\\metcollect"
    $interval = 300
    $write = $::config::collectd_write

    if $write {
        $metcollect_enabled = true
    }
}

