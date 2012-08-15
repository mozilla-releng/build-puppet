class packages::mercurial {
    case $operatingsystem {
        CentOS: {
            package {
                "mercurial":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
