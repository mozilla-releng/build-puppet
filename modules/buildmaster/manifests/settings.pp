# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class buildmaster::settings {
    include ::config
    include users::builder

    $master_root = '/builds/buildbot'
    $queue_dir   = "${master_root}/queue"
    $lock_dir    = "/var/lock/${users::builder::username}"

    case $::config::org {
        seamonkey: {
            $postrun_template = 'postrun-seamonkey.cfg.erb'
        }
        default: {
            $postrun_template = 'postrun-default.cfg.erb'
        }
    }
}
