class packages::mozilla::python26 {
    anchor {
        'packages::mozilla::python26::begin': ;
        'packages::mozilla::python26::end': ;
    }

    Anchor['packages::mozilla::python26::begin'] ->
    case $::operatingsystem {
        CentOS: {
            package {
                "mozilla-python26":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                python26:
                    version => "2.6.7-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::mozilla::python26::end']
}
