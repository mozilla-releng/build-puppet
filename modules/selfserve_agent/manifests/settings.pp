# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class selfserve_agent::settings {
    include ::config

    $root         = $::config::selfserve_agent_root
    $buildapi_dst = "${root}/buildapi"
    $logfile      = "${root}/agent.log"
}
