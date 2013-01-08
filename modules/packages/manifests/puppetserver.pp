class packages::puppetserver {
    include packages::puppet

    # puppet-server requires passenger, which is in its own repo
    realize(Packages::Yumrepo['passenger'])

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
