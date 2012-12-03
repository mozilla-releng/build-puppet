class packages::mozilla::retry {
    case $::operatingsystem {
        Darwin,CentOS: {
            file  {
                "/usr/local/bin/retry.py":
                    source => "puppet:///modules/packages/retry.py",
                    owner => "$users::root::username",
                    group => "$users::root::group",
                    mode => 0755;
            }
        }
        default: {
            fail("Don't know where to put retry on this platform")
        }
    }
}
