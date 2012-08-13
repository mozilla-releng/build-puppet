class packages::mozilla::python27 {
    anchor {
        'packages::mozilla::python27::begin': ;
        'packages::mozilla::python27::end': ;
    }

    Anchor['packages::mozilla::python27::begin'] ->
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-python27":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                python27:
                    version => "2.7.2-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::mozilla::python27::end']
}
