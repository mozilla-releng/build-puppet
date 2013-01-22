class packages::xcode_cmdline_tools {

  # the dmg is available from https://developer.apple.com/downloads

  anchor {
        'packages::xcode_cmdline_tools::begin': ;
        'packages::xcode_cmdline_tools::end': ;
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            #doesn't apply on these platforms
        }
        Darwin: {
            Anchor['packages::xcode_cmdline_tools::begin'] ->
            packages::pkgdmg {
                "command_line_tools_for_xcode_4.5_os_x_mountain_lion":
                    version => "4.5",
                    private => true,
                    dmgname => "command_line_tools_for_xcode_4.5_os_x_mountain_lion.dmg";
            } -> Anchor['packages::xcode_cmdline_tools::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }

}
