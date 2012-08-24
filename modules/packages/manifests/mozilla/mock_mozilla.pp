class packages::mozilla::mock_mozilla {
    case $::operatingsystem {
        CentOS: {
            package {
                "mock_mozilla":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
