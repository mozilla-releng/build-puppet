# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class releaserunner3 {
    include ::config
    include dirs::builds
    include users::builder
    include packages::gcc
    include releaserunner3::settings
    include releaserunner3::services
    include packages::mozilla::python27
    include packages::mozilla::python3

    $env_config = $config::releaserunner3_env_config[$releaserunner3_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python::virtualenv {
        $releaserunner3::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => [
                Class['packages::mozilla::python27'],
            ],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("releaserunner3/requirements.txt");
    }

    file {
        "${releaserunner3::settings::root}/release-runner.yml":
            require   => Python::Virtualenv[$releaserunner3::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template('releaserunner3/release-runner.yml.erb'),
            show_diff => false;
    }

    mercurial::repo {
        'releaserunner3-tools':
            require => Python::Virtualenv[$releaserunner3::settings::root],
            hg_repo => $config::releaserunner_tools,
            dst_dir => $releaserunner3::settings::tools_dst,
            user    => $users::builder::username,
            branch  => $config::releaserunner_tools_branch,
    }
}
