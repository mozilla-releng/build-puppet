# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class releaserunner {
    include ::config
    include dirs::builds
    include users::builder
    include releaserunner::settings
    include releaserunner::services
    include packages::mozilla::python27
    include packages::gcc
    include packages::libffi
    include packages::make
    include packages::mysql_devel

    $env_config = $config::releaserunner_env_config[$releaserunner_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
    }

    python::virtualenv {
        $releaserunner::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => [
                Class['packages::mozilla::python27'],
                Class['packages::libffi'],
            ],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("releaserunner/requirements.txt");
    }

    file {
        "${releaserunner::settings::root}/release-runner.ini":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template('releaserunner/release-runner.ini.erb'),
            show_diff => false;
        "${releaserunner::settings::root}/release-runner.yml":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template('releaserunner/release-runner.yml.erb'),
            show_diff => false;
        "${users::builder::home}/.ssh/release-runner":
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => secret('releaserunner_ssh_key'),
            show_diff => false;
        "${releaserunner::settings::root}/docker-worker-pub.pem":
            require => Python::Virtualenv[$releaserunner::settings::root],
            owner   => $users::builder::username,
            group   => $users::builder::group,
            source  => "puppet:///modules/${module_name}/docker-worker-pub.pem";
        # XXX: Todo name funsize_signing_pvt_key better for current use-case
        "${releaserunner::settings::root}/id_rsa":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => secret('funsize_signing_pvt_key'),
            show_diff => false;
    }

    mercurial::repo {
        'releaserunner-tools':
            require => Python::Virtualenv[$releaserunner::settings::root],
            hg_repo => $config::releaserunner_tools,
            dst_dir => $releaserunner::settings::tools_dst,
            user    => $users::builder::username,
            branch  => $config::releaserunner_tools_branch,
    }
}
