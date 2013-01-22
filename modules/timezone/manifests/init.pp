class timezone {

    include packages::tzdata

    case $::operatingsystem {
        CentOS: {
            file {
                "/etc/localtime":
                    mode => 644,
                    owner => root,
                    group => $users::root::group,
                    content => file("/usr/share/zoneinfo/US/Pacific"),
                    force => true,
                    require => Class['packages::tzdata'];
            }
            exec {
                "/usr/sbin/tzdata-update":
                    subscribe => File["/etc/localtime"],
                    refreshonly => true;
            }
        }
        Ubuntu: {
            file {
                "/etc/timezone":
                    mode => 644,
                    owner => root,
                    group => $users::root::group,
                    content => "America/Los_Angeles\n",
                    force => true,
                    require => Class['packages::tzdata'];
            }
            exec {
                "dpkg-reconfigure-tzdata":
                    command     => "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata",
                    subscribe   => File["/etc/timezone"],
                    refreshonly => true;
            }
        }
        Darwin: {
            osxutils::systemsetup {
                timezone:
                    setting => "America/Los_Angeles";
            }
        }
    }
}
