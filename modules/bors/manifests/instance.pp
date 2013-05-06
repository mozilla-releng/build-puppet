define bors::instance($basedir, $owner, $group, $repo_owner, $repo, $reviewers,
                      $builders, $buildbot_url, $bors_user, $bors_pass,
                      $test_ref = "auto", $master_ref = "incoming",
                      $n_builds = "5", $bors_version = "1.0") {
    bors::install {
        $title:
            basedir => $basedir,
            owner => $owner,
            group => $group,
            version => $bors_version;
    }

    bors::config {
        $title:
            basedir => $basedir,
            owner => $owner,
            group => $group,
            repo_owner => $repo_owner,
            repo => $repo,
            reviewers => $reviewers,
            builders => $builders,
            buildbot_url => $buildbot_url,
            test_ref => $test_ref,
            master_ref => $master_ref,
            n_builds => $n_builds,
            bors_user => $bors_user,
            bors_pass => $bors_pass;
    }

    bors::cron {
        $title:
            basedir => $basedir,
            owner => $owner,
            require => [Bors::Install[$title], Bors::Config[$title]];
    }
}
