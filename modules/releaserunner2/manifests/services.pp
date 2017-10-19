# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class releaserunner2::services {
    include ::config
    include packages::mozilla::supervisor
    include releaserunner2::settings

    supervisord::supervise {
        'releaserunner2':
            command      => "${releaserunner2::settings::tools_dst}/buildfarm/release/release-runner2.sh ${releaserunner2::settings::root} ${releaserunner2::settings::logfile} ${releaserunner2::settings::root}/${config::releaserunner2_env_config[$releaserunner2_env]['releaserunner_config_file']}",
            user         => $::config::builder_username,
            require      => [ File["${releaserunner2::settings::root}/${config::releaserunner2_env_config[$releaserunner2_env]['releaserunner_config_file']}"],
                              Python::Virtualenv[$releaserunner2::settings::root],
                              Mercurial::Repo['releaserunner2-tools']],
            extra_config => template("${module_name}/extra_config.erb")
    }
}
