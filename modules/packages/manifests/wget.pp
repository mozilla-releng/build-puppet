class packages::wget {
    anchor {
        'packages::wget::begin': ;
        'packages::wget::end': ;
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            Anchor['packages::wget::begin'] ->
            package {
                "wget":
                    ensure => latest;
            } -> Anchor['packages::wget::end']
        }
        Darwin: {
            Anchor['packages::wget::begin'] ->
            packages::pkgdmg {
                wget:
                    version => "1.12-1";
            } -> Anchor['packages::wget::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
