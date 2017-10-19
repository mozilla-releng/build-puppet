# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class releaserunner3::services {
    include ::config
    include packages::mozilla::supervisor
    include releaserunner3::settings

    supervisord::supervise {
        'releaserunner3':
            command      => "${releaserunner3::settings::tools_dst}/buildfarm/release/release-runner3.sh ${releaserunner3::settings::root} ${releaserunner3::settings::logfile} ${releaserunner3::settings::root}/${config::releaserunner3_env_config[$releaserunner3_env]['releaserunner_config_file']}",
            user         => $::config::builder_username,
            require      => [ File["${releaserunner3::settings::root}/${config::releaserunner3_env_config[$releaserunner3_env]['releaserunner_config_file']}"],
                              Python::Virtualenv[$releaserunner3::settings::root],
                              Mercurial::Repo['releaserunner3-tools']],
            extra_config => template("${module_name}/extra_config.erb")
    }
}
