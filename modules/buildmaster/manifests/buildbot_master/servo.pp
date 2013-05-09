# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Set up a servo buildbot master. This is just a buildmaster::buildbot_master::simple
# with a passwords file.
#
define buildmaster::buildbot_master::servo($basedir, $http_port) {
    include users::builder
    include buildmaster::settings

    $master_group = "${users::builder::group}"
    $master_user = "${users::builder::username}"
    $master_basedir = "${buildmaster::settings::master_root}"
    $full_master_dir = "${master_basedir}/${basedir}"

    buildmaster::buildbot_master::simple {
        "$title":
            basedir => $basedir,
            http_port => $http_port,
            master_cfg => "puppet:///modules/buildmaster/servo/master.cfg";
    }

    file {
        "${full_master_dir}/master/passwords.py":
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/servo-passwords.py.erb");
    }
}
