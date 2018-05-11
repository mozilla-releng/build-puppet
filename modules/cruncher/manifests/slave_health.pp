# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher::slave_health {
    include ::config
    include users::buildduty
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial

    python::virtualenv {
        '/home/buildduty/slave_health':
            python          => $::packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => [
                Class['packages::mozilla::python27'],
            ],
            user            => $users::buildduty::username,
            group           => $users::buildduty::group,
            packages        => file("cruncher/slave_health_requirements.txt");
    }

    mercurial::repo {
        'slave_health-clone':
            hg_repo => 'https://hg.mozilla.org/build/slave_health',
            dst_dir => '/home/buildduty/slave_health/slave_health',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                Python::Virtualenv['/home/buildduty/slave_health'],
            ];
        'slave_health-config-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbot-configs',
            dst_dir => '/home/buildduty/slave_health/buildbot-configs',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                Python::Virtualenv['/home/buildduty/slave_health'],
            ];
        'slave_health-tools-clone':
            hg_repo => 'https://hg.mozilla.org/build/tools',
            dst_dir => '/home/buildduty/slave_health/tools',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                Python::Virtualenv['/home/buildduty/slave_health'],
            ];
    }

    exec {
        'slave_health.py':
            name      => '/bin/cp /home/buildduty/slave_health/slave_health/scripts/slave_health.py /home/buildduty/slave_health/slave_health.py',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Mercurial::Repo['slave_health-clone'],
            ],
            creates   => '/home/buildduty/slave_health/slave_health.py';
        'slave_health_cron.sh':
            name      => '/bin/cp /home/buildduty/slave_health/slave_health/scripts/slave_health_cron.sh /home/buildduty/slave_health/slave_health_cron.sh',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Mercurial::Repo['slave_health-clone'],
            ],
            creates   => '/home/buildduty/slave_health/slave_health_cron.sh';
        'buildduty_report.sh':
            name      => '/bin/cp /home/buildduty/slave_health/slave_health/scripts/buildduty_report.sh /home/buildduty/slave_health/buildduty_report.sh',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Mercurial::Repo['slave_health-clone'],
            ],
            creates   => '/home/buildduty/slave_health/buildduty_report.sh';
        }

    file {
        '/home/buildduty/slave_health/config_builders.py':
            ensure  => 'link',
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => [
                Mercurial::Repo['slave_health-config-clone'],
            ],
            target  => '/home/buildduty/slave_health/buildbot-configs/mozilla/production_config.py';
        '/home/buildduty/slave_health/config_testers.py':
            ensure  => 'link',
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => [
                Mercurial::Repo['slave_health-config-clone'],
            ],
            target  => '/home/buildduty/slave_health/buildbot-configs/mozilla-tests/production_config.py';
        '/home/buildduty/slave_health/buildduty_report.py':
            ensure  => 'link',
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => [
                Mercurial::Repo['slave_health-clone'],
            ],
            target  => '/home/buildduty/slave_health/slave_health/scripts/buildduty_report.py';
        '/home/buildduty/slave_health/last_build_creds.py':
            content => template('cruncher/last_build_creds.py.erb'),
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            mode    => '0600',
            require => [
                Mercurial::Repo['slave_health-clone'],
            ];
    }
}
