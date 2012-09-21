class packages::tzdata {
    case $::operatingsystem {
        CentOS: {
            package {
                "tzdata":
                    ensure => latest;
            }
        }
    }
}
