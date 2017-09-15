# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class releaserunner2::settings {
    include ::config

    $root      = $config::releaserunner2_root
    $tools_dst = "${root}/tools"
    $logfile   = "${root}/release-runner2.log"
}
