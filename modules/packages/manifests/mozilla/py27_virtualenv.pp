class packages::mozilla::py27_virtualenv {
    anchor {
        'packages::mozilla::py27_virtualenv::begin': ;
        'packages::mozilla::py27_virtualenv::end': ;
    }

    include packages::mozilla::python27

    case $::operatingsystem {
        CentOS: {
	    Anchor['packages::mozilla::py27_virtualenv::begin'] ->
            package {
                "mozilla-python27-virtualenv":
                    ensure => latest,
                    require => Class['packages::mozilla::python27'];
            } -> Anchor['packages::mozilla::py27_virtualenv::end']
        }
        Darwin: {
	    Anchor['packages::mozilla::py27_virtualenv::begin'] ->
            packages::pkgdmg {
                python27-virtualenv:
                    version => "1.7.1.2-1";
            } -> Anchor['packages::mozilla::py27_virtualenv::end']
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
