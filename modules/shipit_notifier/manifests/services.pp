# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class shipit_notifier::services {
    include ::config
    include packages::mozilla::supervisor
    include shipit_notifier::settings

    supervisord::supervise {
        "shipit_notifier":
            command      => "${shipit_notifier::settings::root}/bin/python ${shipit_notifier::settings::tools_dst}/buildfarm/release/shipit-notifier.py -c ${shipit_notifier::settings::root}/shipit_notifier.ini",
            user         => $::config::builder_username,
            require      => [File["${shipit_notifier::settings::root}/shipit_notifier.ini"],
                             Python::Virtualenv["${shipit_notifier::settings::root}"],
                             Mercurial::Repo["shipit_notifier_tools"]],
            extra_config => template("${module_name}/extra_config.erb")
    }
}
