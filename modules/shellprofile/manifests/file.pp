define shellprofile::file($content) {
    include shellprofile::base
    include users::root

    case ($::operatingsystem) {
        CentOS: {
            file {
                "/etc/profile.puppet.d/${title}.sh":
                    owner => $users::root::username,
                    group => $users::root::group,
                    content => "${content}\n";
            }
        }
    }
}
