# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildbot_bridge2::settings {
    include ::config

    $root = $config::buildbot_bridge2_root
    $env_config = $config::buildbot_bridge2_env_config[$buildbot_bridge2_env]
}
