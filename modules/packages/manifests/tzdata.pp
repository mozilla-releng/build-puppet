class packages::tzdata {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                "tzdata":
                    ensure => latest;
            }
        }
    }
}
