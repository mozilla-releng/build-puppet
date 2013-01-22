class packages::java {

  # the dmg is available from https://developer.apple.com/downloads

  anchor {
        'packages::java::begin': ;
        'packages::java::end': ;
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            #doesn't apply on these platforms
        }
        Darwin: {
            Anchor['packages::xcode_cmdline_tools::begin'] ->
            packages::pkgdmg {
                "javadeveloper_for_os_x_2012003__11m3646":
                    version => "2012003__11m3646",
                    private => true,
                    dmgname => "javadeveloper_for_os_x_2012003__11m3646.dmg";
            } -> Anchor['packages::java::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }

}
