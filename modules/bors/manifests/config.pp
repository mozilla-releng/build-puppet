define bors::config($basedir, $owner, $group, $repo_owner, $repo, $reviewers,
                    $builders, $buildbot_url, $bors_user, $bors_pass,
                    $test_ref, $master_ref, $n_builds = "5") {
    file {
        "${basedir}/bors.cfg":
            mode => 600,
            owner => $owner,
            group => $group,
            content => template("bors/bors.cfg.erb")
    }
}
