class packages::mozilla::python27 {
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
    }
}
