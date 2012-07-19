class packages::mozilla::python26 {
    case $operatingsystem{
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
    }
}
