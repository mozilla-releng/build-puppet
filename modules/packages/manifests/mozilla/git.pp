class packages::mozilla::git {
    anchor {
        'packages::mozilla::git::begin': ;
        'packages::mozilla::git::end': ;
    }

    Anchor['packages::mozilla::git::begin'] ->
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-git":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                git:
                    version => "1.7.9.4-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::mozilla::git::end']
}
