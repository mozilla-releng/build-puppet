class packages::mozilla::git {
    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-git":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
