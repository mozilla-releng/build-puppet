class packages::mozilla::git {
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-git":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                git:
                    version => "1.7.9.4-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
