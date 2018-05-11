# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster::db_maintenance
#
# this class manages cleanup functionality for the buildbot databases
# Instantiate this on one of the buildmaster nodes

class buildmaster::db_maintenance {
    include users::builder
    include packages::mozilla::python27
    include buildmaster::settings

    $db_maintenance_dir = "${buildmaster::settings::master_root}/db_maint"

    mercurial::repo {
        'buildmaster::db_maintenance::tools':
            require => File[$db_maintenance_dir],
            hg_repo => $config::buildbot_tools_hg_repo,
            dst_dir => "${db_maintenance_dir}/tools",
            user    => $users::builder::username,
            branch  => 'default';
    }

    python::virtualenv {
        $db_maintenance_dir:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("buildmaster/db_maintenance_requirements.txt");
    }

    file {
        '/etc/cron.d/buildbot_db_maintenance':
            require => [Python::Virtualenv[$db_maintenance_dir], Mercurial::Repo['buildmaster::db_maintenance::tools']],
            mode    => '0600',
            content => template('buildmaster/buildmaster-db-maintenance.erb');
        "${db_maintenance_dir}/config.ini":
            owner     => $users::builder::username,
            group     => $users::builder::group,
            mode      => '0600',
            content   => template('buildmaster/buildmaster-db-maintenance-config.erb'),
            show_diff => false;
    }
}
