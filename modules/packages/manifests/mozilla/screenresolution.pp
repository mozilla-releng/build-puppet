class packages::mozilla::screenresolution {
    anchor {
        'packages::mozilla::screenresolution::begin': ;
        'packages::mozilla::screenresolution::end': ;
    }

    Anchor['packages::mozilla::screenresolution::begin'] ->
    case $::operatingsystem {
        CentOS : {
            # doesn't apply
        }
        Darwin : {
             packages::pkgdmg {
                screenresolution:
                    version => "1.6";
             }
        }
        default : {
            fail("cannot install on $::operatingsystem")
        }
    } -> Anchor['packages::mozilla::screenresolution::end']
}
