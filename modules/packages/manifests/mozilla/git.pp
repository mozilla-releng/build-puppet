class packages::mozilla::git {
    anchor {
        'packages::mozilla::git::begin': ;
        'packages::mozilla::git::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::git::begin'] ->
            package {
                "mozilla-git":
                    ensure => latest;
            } -> Anchor['packages::mozilla::git::end']
        }
        Darwin: {
            Anchor['packages::mozilla::git::begin'] ->
            packages::pkgdmg {
                git:
                    version => "1.7.9.4-1";
            } -> Anchor['packages::mozilla::git::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
