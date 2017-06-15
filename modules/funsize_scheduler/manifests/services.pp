# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class funsize_scheduler::services {
    include ::config
    include funsize_scheduler::conf
    include funsize_scheduler::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        'funsize_scheduler':
            command      => "${funsize_scheduler::settings::root}/bin/funsize-scheduler -c ${funsize_scheduler::settings::root}/config.yml",
            user         => $::config::builder_username,
            require      => [File["${funsize_scheduler::settings::root}/config.yml"],
                            Python::Virtualenv[$funsize_scheduler::settings::root]],
            extra_config => template("${module_name}/funsize_scheduler_supervisor_config.erb");
    }

    exec {
        'restart-funsize-scheduler':
            command     => '/usr/bin/supervisorctl restart funsize_scheduler',
            refreshonly => true,
            subscribe   => [Python::Virtualenv[$funsize_scheduler::settings::root],
                            File["${funsize_scheduler::settings::root}/config.yml"]];
    }
}
