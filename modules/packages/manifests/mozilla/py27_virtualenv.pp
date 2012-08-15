class packages::mozilla::py27_virtualenv {
    anchor {
        'packages::mozilla::py27_virtualenv::begin': ;
        'packages::mozilla::py27_virtualenv::end': ;
    }

    include packages::mozilla::python27

    Anchor['packages::mozilla::py27_virtualenv::begin'] ->
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-python27-virtualenv":
                    ensure => latest,
                    require => Class['packages::mozilla::python27'];
            }
        }
        Darwin: {
            packages::pkgdmg {
                python27-virtualenv:
                    version => "1.7.1.2-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::mozilla::py27_virtualenv::end']
}
