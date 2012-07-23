class packages::mozilla::screenresolution {
    case $operatingsystem {
        CentOS : {
            # doesn't apply
        }
        Darwin : {
             packages::pkgdmg {
                screenresolution:
                    version => "1.6";
             }
        }
        default : {
            fail("cannot install on $operatingsystem")
        }
    }
}
