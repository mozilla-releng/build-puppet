class packages::hp_health {
    realize(Packages::Yumrepo['hp-proliantsupportpack'])

    case $::operatingsystem {
        CentOS: {
            package {
                "hp-health":
                    ensure => latest;
                # this isn't listed as a prereq, but this utility needs the i386 lib
                # to run successfully
                "libgcc.i686":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
