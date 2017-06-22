# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class selfserve_agent::services {
    include ::config
    include packages::mozilla::supervisor
    include selfserve_agent::settings
    include nrpe::settings

    file {
        "${selfserve_agent::settings::root}/selfserve-agent.ini":
            content   => template('selfserve_agent/selfserve-agent.ini.erb'),
            require   => Python::Virtualenv[$selfserve_agent::settings::root],
            mode      => '0600',
            owner     => $::config::builder_username,
            group     => $::config::builder_group,
            show_diff => false;
    }

    supervisord::supervise {
        'selfserve-agent':
            command      => "${selfserve_agent::settings::root}/bin/selfserve-agent --config-file ${selfserve_agent::settings::root}/selfserve-agent.ini --wait -v",
            user         => $::config::builder_username,
            require      => [ File["${selfserve_agent::settings::root}/selfserve-agent.ini"],
                              Python::Virtualenv[$selfserve_agent::settings::root]],
            extra_config => template("${module_name}/extra_config.erb");
    }

    exec {
        'restart-selfserve-agent':
            command     => '/usr/bin/supervisorctl restart selfserve-agent',
            refreshonly => true,
            subscribe   => Python::Virtualenv[$selfserve_agent::settings::root];
    }

    nrpe::check {
        'check_selfserve-agent':
            cfg => "${nrpe::settings::plugins_dir}/check_procs -c 1:1 -a bin/selfserve-agent";
    }

}
