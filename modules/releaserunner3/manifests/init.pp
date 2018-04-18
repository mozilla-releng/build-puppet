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
    include packages::mozilla::python35

    $env_config = $config::releaserunner3_env_config[$releaserunner3_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/sbin/service ${module_name} stop",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python35'];
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
            packages        => [
                'PyYAML==3.12',
                'Twisted==12.3.0',
                'certifi==2017.07.27.1',
                'chardet==3.0.4',
                'idna==2.6',
                'json-e==2.5.0',
                'mohawk==0.3.4',
                'requests==2.18.4',
                'simplejson==3.11.1',
                'six==1.11.0',
                'slugid==1.0.7',
                'taskcluster==1.3.5',
                'urllib3==1.22',
                'wsgiref==0.1.2',
                'zope.interface==4.4.3',
            ];
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
