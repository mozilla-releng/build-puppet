# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildbot_bridge::conf {
    include ::config
    include buildbot_bridge::settings
    include dirs::builds
    include users::builder
    include packages::logrotate

    $env_config = $::buildbot_bridge::settings::env_config

    file {
        "${buildbot_bridge::settings::root}/config.json":
            require   => Python::Virtualenv[$buildbot_bridge::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/config.json.erb"),
            show_diff => false;
    }
}
