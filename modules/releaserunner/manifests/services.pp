# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class releaserunner::services {
    include ::config
    include packages::mozilla::supervisor
    include releaserunner::settings

    supervisord::supervise {
        "releaserunner":
            command      => "${releaserunner::settings::tools_dst}/buildfarm/release/release-runner.sh ${releaserunner::settings::root} ${releaserunner::settings::logfile} ${releaserunner::settings::root}/release-runner.ini",
            user         => $::config::builder_username,
            require      => [ File["${releaserunner::settings::root}/release-runner.ini"],
                              Python::Virtualenv["${releaserunner::settings::root}"],
                              Mercurial::Repo["releaserunner-tools"]],
            extra_config => template("${module_name}/extra_config.erb")
    }
}
