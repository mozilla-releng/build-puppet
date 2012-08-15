class packages::mozilla::py27_mercurial {
    anchor {
        'packages::mozilla::py27_mercurial::begin': ;
        'packages::mozilla::py27_mercurial::end': ;
    }

    include packages::mozilla::python27

    Anchor['packages::mozilla::py27_mercurial::begin'] ->
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-python27-mercurial":
                    ensure => latest,
                    require => Class['packages::mozilla::python27'];
            }
        }
        Darwin: {
            packages::pkgdmg {
                python27-mercurial:
                    version => "2.1.1-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::mozilla::py27_mercurial::end']
}
