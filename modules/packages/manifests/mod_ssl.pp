class packages::mod_ssl {
    case $operatingsystem {
        CentOS: {
            package {
                "mod_ssl":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
