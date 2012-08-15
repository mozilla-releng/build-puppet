class packages::puppetserver {
    include packages::puppet

    case $operatingsystem {
        CentOS: {
            package {
                "puppet-server":
                    require => Class["packages::puppet"],
                    ensure => $packages::puppet::puppet_rpm_version;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
