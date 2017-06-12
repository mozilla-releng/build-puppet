# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Set up a particular "mozilla" buildbot master instance
# The master information must already be in production-masters.json and setup-masters.py
# "mozilla" refers to the set of masters defined in https://hg.mozilla.org/build/buildbot-configs
#
# $basedir refers to the name of the directory under $master_basedir
# (/builds/buildbot) where the master's files will live. It corresponds to the
# 'basedir' key in the masters json.
#
# The master's name must reference one of the masters supported by setup-masters.py
#
# $master_type must be one of 'build', 'try', 'tests', or 'scheduler'
#
define buildmaster::buildbot_master::mozilla($basedir, $master_type, $http_port=undef) {
    include ::config
    include buildmaster::base

    $master_group         = $users::builder::group
    $master_user          = $users::builder::username
    $master_basedir       = $buildmaster::settings::master_root
    $master_name          = $name
    $full_master_dir      = "${master_basedir}/${basedir}"
    $buildbot_configs_dir = "${full_master_dir}/buildbot-configs"

    # Different types of masters require different BuildSlaves.py files
    $buildslaves_template = "BuildSlaves-${master_type}.py.erb"

    file {
        "${full_master_dir}/master/BuildSlaves.py":
            require   => Exec["setup-${basedir}"],
            owner     => $master_user,
            group     => $master_group,
            mode      => '0600',
            content   => template("buildmaster/${buildslaves_template}"),
            show_diff => false;
        $full_master_dir:
            ensure => 'directory',
            owner  => $master_user,
            group  => $master_group;
        "${full_master_dir}/master/passwords.py":
            require   => Exec["setup-${basedir}"],
            owner     => $master_user,
            group     => $master_group,
            mode      => '0600',
            content   => template('buildmaster/passwords.py.erb'),
            show_diff => false;
        "${full_master_dir}/master/buildbot.tac":
            require => Exec["setup-${basedir}"],
            mode    => '0644',
            owner   => $master_user,
            group   => $master_group,
            source  => 'puppet:///modules/buildmaster/buildbot.tac';
        "/etc/default/buildbot.d/${master_name}":
            content => $full_master_dir,
            require => Exec["setup-${basedir}"],
            before  => Nrpe::Custom['buildbot.cfg'];
        "/etc/cron.d/${master_name}":
            require => Exec["setup-${basedir}"],
            mode    => '0600',
            content => template('buildmaster/buildmaster-cron.erb');
    }

    # Scheduler masters don't need postrun.cfg
    if ($master_type != 'scheduler') {
        if ($http_port == undef) {
            fail("Need to specify http_port for ${master_name}")
        }

        file {
            "${full_master_dir}/master/postrun.cfg":
                require   => Exec["setup-${basedir}"],
                owner     => $master_user,
                group     => $master_group,
                mode      => '0600',
                content   => template("buildmaster/${buildmaster::settings::postrun_template}"),
                show_diff => false;
            '/usr/local/bin/buildmaster-retry_dead_queue.sh':
                mode    => '0755',
                require => Exec["setup-${basedir}"],
                source  => 'puppet:///modules/buildmaster/buildmaster-retry_dead_queue.sh';
            '/etc/cron.d/buildmaster-retry_dead_queue':
                mode    => '0644',
                require => Exec["setup-${basedir}"],
                content => template('buildmaster/buildmaster-retry_dead_queue.erb');
        }
    }

    mercurial::repo {
        "clone-buildbot-${master_name}":
            hg_repo => $config::buildbot_configs_hg_repo,
            dst_dir => $buildbot_configs_dir,
            user    => $users::builder::username,
            branch  => $config::buildbot_configs_branch;
    }

    exec {
        "setup-${basedir}":
            require   => [
                Mercurial::Repo["clone-buildbot-${master_name}"],
                File[$full_master_dir],
                Class['packages::mozilla::py27_virtualenv'],
            ],
            command   => "/usr/bin/make -f Makefile.setup all BASEDIR=${full_master_dir} \
                            MASTER_NAME=${master_name} \
                            VIRTUALENV=${::packages::mozilla::py27_virtualenv::virtualenv} \
                            PYTHON=${::packages::mozilla::python27::python} \
                            HG=${::packages::mozilla::py27_mercurial::mercurial} \
                            MASTERS_JSON=${config::master_json} \
                            USER=${master_user} \
                            BUILDBOTCUSTOM_BRANCH=${config::buildbotcustom_branch} \
                            BUILDBOTCONFIGS_BRANCH=${config::buildbot_configs_branch} \
                            TOOLS_REPO=${config::buildbot_tools_hg_repo}",
            creates   => "${full_master_dir}/master",
            user      => $master_user,
            group     => $master_group,
            logoutput => on_failure,
            cwd       => $buildbot_configs_dir;
    }
}
