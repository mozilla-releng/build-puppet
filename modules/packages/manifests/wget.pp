class packages::wget {
    anchor {
        'packages::wget::begin': ;
        'packages::wget::end': ;
    }

    Anchor['packages::wget::begin'] ->
    case $operatingsystem{
        CentOS: {
            package {
                "wget":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                wget:
                    version => "1.12-1";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    } -> Anchor['packages::wget::end']
}
