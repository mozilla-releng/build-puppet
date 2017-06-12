# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Set up a simple buildbot master instance. This involves:
# * Creating a virtualenv and installing Buildbot into it.
# * Installing a buildbot.tac, master.cfg, Makefile, and public_html
# * Installing cron jobs to watch the logs for exceptions and clean up the
#   master directory periodically.
#
define buildmaster::buildbot_master::simple($basedir, $http_port, $master_cfg, $buildbot_version = '0.8.7p1') {
    include ::config
    include dirs::builds::buildbot
    include buildmaster::base
    include buildmaster::settings
    include packages::procmail # for lockfile
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial

    $master_group    = $users::builder::group
    $master_user     = $users::builder::username
    $master_basedir  = $buildmaster::settings::master_root
    $master_name     = $name
    $full_master_dir = "${master_basedir}/${basedir}"

    file {
        "/etc/default/buildbot.d/${master_name}":
            content => $full_master_dir,
            before  => Nrpe::Custom['buildbot.cfg'];
        "/etc/cron.d/${master_name}":
            mode    => '0600',
            content => template('buildmaster/buildmaster-cron.erb');
        "${full_master_dir}/master":
            ensure  => directory,
            owner   => $master_user,
            group   => $master_group,
            mode    => '0755',
            require => Python::Virtualenv[$full_master_dir];
        "${full_master_dir}/Makefile":
            mode    => '0644',
            owner   => $master_user,
            group   => $master_group,
            source  => 'puppet:///modules/buildmaster/Makefile',
            require => Python::Virtualenv[$full_master_dir];
        "${full_master_dir}/master/master.cfg":
            mode   => '0644',
            owner  => $master_user,
            group  => $master_group,
            source => $master_cfg;
        "${full_master_dir}/master/buildbot.tac":
            mode   => '0644',
            owner  => $master_user,
            group  => $master_group,
            source => 'puppet:///modules/buildmaster/buildbot.tac';
        "${full_master_dir}/master/public_html":
            mode   => '0755',
            owner  => $master_user,
            group  => $master_group,
            source => 'puppet:///modules/buildmaster/public_html';
    }

    exec {
        "${full_master_dir}-tools":
            name      => "${::packages::mozilla::py27_mercurial::mercurial} clone ${config::buildbot_tools_hg_repo} ${full_master_dir}/tools",
            user      => $master_user,
            logoutput => on_failure,
            require   => [
                File[$full_master_dir],
                Class['packages::mozilla::py27_mercurial'],
            ],
            creates   => "${full_master_dir}/tools";
    }

    # Actual master setup TBD
    python::virtualenv {
        $full_master_dir:
            python   => $::packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
                File['/builds/buildbot']
            ],
            user     => $master_user,
            group    => $master_group,
            packages => [
                "buildbot==${buildbot_version}",
                'Twisted==10.2.0',
                'Jinja2==2.5.5',
                'SQLAlchemy==0.7.9',
                'sqlalchemy-migrate==0.7.2',
                'python-dateutil==1.5',
                'zope.interface==3.6.1',
                'Tempita==0.5.1',
                'decorator==3.4.0',
                'MySQL-python==1.2.3',
            ];
    }
}
