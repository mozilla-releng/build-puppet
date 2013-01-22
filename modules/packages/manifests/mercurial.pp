class packages::mercurial {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                "mercurial":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
