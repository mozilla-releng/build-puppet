# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bors::instance($basedir, $owner, $group, $repo_owner, $repo, $reviewers,
                      $builders, $buildbot_url, $bors_user, $bors_pass,
                      $test_ref = 'auto', $master_ref = 'master',
                      $n_builds = '5', $bors_version = '1.2',
                      $status_location = null) {
    bors::install {
        $title:
            basedir => $basedir,
            owner   => $owner,
            group   => $group,
            version => $bors_version;
    }

    bors::config {
        $title:
            basedir      => $basedir,
            owner        => $owner,
            group        => $group,
            repo_owner   => $repo_owner,
            repo         => $repo,
            reviewers    => $reviewers,
            builders     => $builders,
            buildbot_url => $buildbot_url,
            test_ref     => $test_ref,
            master_ref   => $master_ref,
            n_builds     => $n_builds,
            bors_user    => $bors_user,
            bors_pass    => $bors_pass;
    }

    bors::cron {
        $title:
            basedir         => $basedir,
            owner           => $owner,
            status_location => $status_location,
            require         => [Bors::Install[$title], Bors::Config[$title]];
    }

    if ($status_location != null) {
        bors::status {
            $title:
                owner           => $owner,
                group           => $group,
                repo_owner      => $repo_owner,
                repo            => $repo,
                status_location => $status_location;
        }
    }
}
