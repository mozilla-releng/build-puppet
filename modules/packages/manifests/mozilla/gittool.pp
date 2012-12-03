class packages::mozilla::gittool {
    case $::operatingsystem {
        Darwin,CentOS: {
            file  {
                "/usr/local/bin/gittool.py":
                    source => "puppet:///modules/packages/gittool.py",
                    owner => "$users::root::username",
                    group => "$users::root::group",
                    mode => 0755;
            }
        }
        default: {
            fail("Don't know where to put gittool on this platform")
        }
    }
}
