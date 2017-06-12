# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster::buildmaster::settings::queue class
# sets up buildmaster::settings::queue processors for pulse, commands, etc.

class buildmaster::queue {
    include ::config
    include buildmaster::settings
    include users::builder
    include packages::mozilla::python27

    file {
        '/etc/init.d/command_runner':
            content => template('buildmaster/command_runner.initd.erb'),
            notify  => Service['command_runner'],
            mode    => '0755';
        '/etc/init.d/pulse_publisher':
            content => template('buildmaster/pulse_publisher.initd.erb'),
            notify  => Service['pulse_publisher'],
            mode    => '0755';
        "${buildmaster::settings::queue_dir}/run_command_runner.sh":
            ensure => absent;
        "${buildmaster::settings::queue_dir}/run_pulse_publisher.sh":
            ensure => absent;
        "${buildmaster::settings::queue_dir}/passwords.py":
            require   => Python::Virtualenv[$buildmaster::settings::queue_dir],
            content   => template('buildmaster/passwords.py.erb'),
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::username,
            show_diff => false;
    }
    service {
        'command_runner':
            ensure    => running,
            hasstatus => true,
            subscribe => Python::Virtualenv[$buildmaster::settings::queue_dir],
            require   => [
                File['/etc/init.d/command_runner'],
                Exec['install-tools'],
                ],
            enable    => true;
        'pulse_publisher':
            ensure    => running,
            hasstatus => true,
            subscribe => [
                Python::Virtualenv[$buildmaster::settings::queue_dir],
                File["${buildmaster::settings::queue_dir}/passwords.py"],
            ],
            require   => [
                File['/etc/init.d/pulse_publisher'],
                File["${buildmaster::settings::queue_dir}/passwords.py"],
                Exec['install-tools'],
                ],
            enable    => true;
    }

    python::virtualenv {
        $buildmaster::settings::queue_dir:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                'buildbot==0.8.4-pre-moz2',
                'MozillaPulse==1.2.1',
                'amqp==1.4.6',
                'anyjson==0.3.3',
                'kombu==3.0.23',
                'pytz==2015.6',
            ];
    }

    nrpe::custom {
        'pulse_publisher.cfg':
            content => template('buildmaster/pulse_publisher.cfg.erb');
        'command_runner.cfg':
            content => template('buildmaster/command_runner.cfg.erb');
    }

    mercurial::repo {
        'clone-tools':
            hg_repo => $config::buildbot_tools_hg_repo,
            dst_dir => "${buildmaster::settings::queue_dir}/tools",
            user    => $users::builder::username,
            branch  => 'default';
    }

    exec {
        'install-tools':
            require => [
                File[$buildmaster::settings::queue_dir],
                Python::Virtualenv[$buildmaster::settings::queue_dir],
                Mercurial::Repo['clone-tools'],
                ],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop",
            cwd     => "${buildmaster::settings::queue_dir}/tools",
            user    => $users::builder::username,
            group   => $users::builder::group;
    }
}
