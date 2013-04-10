# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Set up a particular buildbot master instance
# The master information must already be in production-masters.json and setup-masters.py
#
# $basedir refers to the name of the directory under $master_basedir
# (/builds/buildbot) where the master's files will live. It corresponds to the
# 'basedir' key in the masters json.
#
# The master's name must reference one of the masters supported by setup-masters.py
#
# $master_type must be one of 'build', 'try', 'tests', or 'scheduler'
#
define buildmaster::buildbot_master($basedir, $master_type, $http_port) {
    include ::config
    include config::secrets
    include buildmaster
    include buildmaster::settings
    include users::builder
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::mozilla::py27_virtualenv

    $master_group = "${users::builder::group}"
    $master_user = "${users::builder::username}"
    $master_basedir = "${buildmaster::settings::master_root}"
    $master_name = "${name}"
    $full_master_dir = "${master_basedir}/${basedir}"
    $buildbot_configs_dir ="${full_master_dir}/buildbot-configs"

    # Different types of masters require different BuildSlaves.py files
    $buildslaves_template = "BuildSlaves-${master_type}.py.erb"

    file {
        "${full_master_dir}/master/BuildSlaves.py":
            require => Exec["setup-$basedir"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/${buildslaves_template}");
        "${full_master_dir}":
            owner => $master_user,
            group => $master_group,
            ensure => "directory";
        "${full_master_dir}/master/passwords.py":
            require => Exec["setup-${basedir}"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/passwords.py.erb");
        "${full_master_dir}/master/postrun.cfg":
            require => Exec["setup-${basedir}"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/postrun.cfg.erb");
        "/etc/default/buildbot.d/${master_name}":
            content => "${full_master_dir}",
            require => Exec["setup-${basedir}"],
            before => Nrpe::Custom["buildbot.cfg"];
        "/etc/cron.d/${master_name}":
            require => Exec["setup-${basedir}"],
            mode => 600,
            content => template("buildmaster/buildmaster-cron.erb");
    }

    buildmaster::repos {
        "clone-buildbot-${master_name}":
            hg_repo => "${config::buildbot_configs_hg_repo}",
            dst_dir => "${buildbot_configs_dir}",
            branch  => "${config::buildbot_configs_branch}";
    }

    exec {
        "setup-${basedir}":
            require => [
                Buildmaster::Repos["clone-buildbot-${master_name}"],
                File["${full_master_dir}"],
                Class["packages::mozilla::py27_virtualenv"],
            ],
            command   => "/usr/bin/make -f Makefile.setup all BASEDIR=${full_master_dir} \
                            MASTER_NAME=${master_name} \
                            VIRTUALENV=${::packages::mozilla::py27_virtualenv::virtualenv} \
                            PYTHON=${::packages::mozilla::python27::python} \
                            HG=${::packages::mozilla::py27_mercurial::mercurial} \
                            MASTERS_JSON=${config::master_json}",
            creates   => "${full_master_dir}/master",
            user      => $master_user,
            group     => $master_group,
            logoutput => on_failure,
            cwd       => "${buildbot_configs_dir}";
    }
}
