# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shipit_notifier::settings {
    include ::config

    $root = $config::shipit_notifier_root
    $tools_dst = "${root}/tools"
    $logfile = "${root}/shipit_notifier.log"
}
