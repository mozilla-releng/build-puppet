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

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-command_runner":
            command     => "/sbin/service command_runner stop",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
        "stop-for-rebuild-pulse_publisher":
            command     => "/sbin/service pulse_publisher stop",
            refreshonly => true,
            subscribe   => Exec['stop-for-rebuild-command_runner'];
    }

    python::virtualenv {
        $buildmaster::settings::queue_dir:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec['stop-for-rebuild-pulse_publisher'],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("buildmaster/queue_requirements.txt");
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

    $mirrors = join($config::user_python_repositories, " --find-links=")

    exec {
        'install-tools':
            require => [
                File[$buildmaster::settings::queue_dir],
                Python::Virtualenv[$buildmaster::settings::queue_dir],
                Mercurial::Repo['clone-tools'],
                ],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop --find-links ${mirrors}",
            cwd     => "${buildmaster::settings::queue_dir}/tools",
            user    => $users::builder::username,
            group   => $users::builder::group;
    }
}
