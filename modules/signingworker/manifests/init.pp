# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla..org/MPL/2.0/.

class signingworker {
    include ::config
    include signingworker::services
    include signingworker::settings
    include dirs::builds
    include packages::mozilla::python27
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
    }

    python::virtualenv {
        $signingworker::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("signingworker/requirements.txt");
    }

    nrpe::custom {
        'signingworker.cfg':
            content => template("${module_name}/nagios.cfg.erb");
    }

    mercurial::repo {
        'signingworker-tools':
            require => Python::Virtualenv[$signingworker::settings::root],
            hg_repo => $config::signingworker_tools_repo,
            dst_dir => $signingworker::settings::tools_dst,
            user    => $users::builder::username,
            branch  => $config::signingworker_tools_branch,
    }

    file {
        "${signingworker::settings::root}/config.json":
            require   => Python::Virtualenv[$signingworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/config.json.erb"),
            show_diff => false;
        "${signingworker::settings::root}/passwords.json":
            require   => Python::Virtualenv[$signingworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/passwords.json.erb"),
            show_diff => false;
        "${signingworker::settings::root}/id_rsa.pub":
            require => Python::Virtualenv[$signingworker::settings::root],
            content => secret('signingworker_pub_key');
    }
}
