# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla..org/MPL/2.0/.

class signingworker::services {
    include ::config
    include signingworker::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        'signingworker':
            command      => "${signingworker::settings::root}/bin/signing-worker --admin.conf ${signingworker::settings::root}/config.json",
            user         => $::config::builder_username,
            require      => [ File["${signingworker::settings::root}/config.json"],
                              File["${signingworker::settings::root}/passwords.json"],
                              Mercurial::Repo['signingworker-tools']],
            extra_config => template("${module_name}/supervisor_config.erb");
    }
    exec {
        'restart-signingworker':
            command     => '/usr/bin/supervisorctl restart signingworker',
            refreshonly => true,
            subscribe   => [Python::Virtualenv[$signingworker::settings::root],
                            File["${signingworker::settings::root}/config.json"],
                            File["${signingworker::settings::root}/id_rsa.pub"],
                            File["${signingworker::settings::root}/passwords.json"]];
    }
}
