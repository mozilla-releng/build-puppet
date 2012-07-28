class packages::wget {
    case $operatingsystem{
        CentOS: {
            package {
                "wget":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                wget:
                    version => "1.12-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
