class screenresolution::talos {
    $width = 1600
    $height = 1200
    $depth = 32
    $refresh = 60
   
    case $::operatingsystem {
        Darwin: {
            include packages::mozilla::screenresolution 
            $resolution = "${width}x${height}x${depth}@${refresh}"

            # this can't run while puppetizing, since the automatic login isn't in place yet, and
            # the login window does not allow screenresolution to run.
            if (!$puppetizing) {
                exec {
                    "set-resolution":
                        command => "/usr/local/bin/screenresolution set $resolution",
                        unless => "/usr/local/bin/screenresolution get 2>&1 | /usr/bin/grep 'Display 0: $resolution'",
                        require => Class["packages::mozilla::screenresolution"];
                }
            }
        }
        default: {
            fail("Don't have a mechanism to set screen resolution on $::operatingsystem")
        }
    }
}
