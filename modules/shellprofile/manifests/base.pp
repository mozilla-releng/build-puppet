class shellprofile::base {
    include users::root

    case ($operatingsystem) {
        CentOS: {
            file {
                "/etc/profile.puppet.d":
                    owner => $users::root::username,
                    group => $users::root::group,
                    ensure => directory,
                    purge => true,
                    recurse => true,
                    force => true;
                "/etc/profile.d/puppetdir.sh":
                    owner => $users::root::username,
                    group => $users::root::group,
                    mode => 0755,
                    source => "puppet:///modules/shellprofile/puppetdir.sh";
            }
        }
        default: {
            fail("shellprofile not supported on $operatingsystem")
            # this is probably possible on OSX, just not implemented yet
        }
    }
}
