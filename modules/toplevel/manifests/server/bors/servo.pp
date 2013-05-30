# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::bors::servo inherits toplevel::server {
    include dirs::builds::bors
    include users::builder

    bors::instance {
        "servo":
            basedir => "/builds/bors/servo",
            owner => "$users::builder::username",
            group => "$users::builder::group",
            repo_owner => "$config::bors_servo_repo_owner",
            repo => "$config::bors_servo_repo",
            reviewers => $config::bors_servo_reviewers,
            builders => $config::bors_servo_builders,
            buildbot_url => "$config::bors_servo_buildbot_url",
            bors_user => secret('bors_servo_gh_user'),
            bors_pass => secret('bors_servo_gh_pass');
    }
}
