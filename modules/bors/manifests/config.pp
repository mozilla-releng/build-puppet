# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bors::config($basedir, $owner, $group, $repo_owner, $repo, $reviewers,
                    $builders, $buildbot_url, $bors_user, $bors_pass,
                    $test_ref, $master_ref, $n_builds = '5') {
    file {
        "${basedir}/bors.cfg":
            mode      => '0600',
            owner     => $owner,
            group     => $group,
            content   => template('bors/bors.cfg.erb'),
            show_diff => false;
    }
}
