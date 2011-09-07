class yum-repo::dir {
    file {
        # this will ensure that any "stray" repos will be deleted
        "/etc/yum.repos.d":
            ensure => directory,
            recurse => true;
    }
}
