class packages::mozilla::python27 {
    anchor {
        'packages::mozilla::python27::begin': ;
        'packages::mozilla::python27::end': ;
    }

    case $::operatingsystem {
        CentOS: {
	    Anchor['packages::mozilla::python27::begin'] ->
            package {
                "mozilla-python27":
                    ensure => latest;
            } -> Anchor['packages::mozilla::python27::end']
        }
        Darwin: {
	    Anchor['packages::mozilla::python27::begin'] ->
            packages::pkgdmg {
                python27:
                    version => "2.7.2-1";
            } -> Anchor['packages::mozilla::python27::end']
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
