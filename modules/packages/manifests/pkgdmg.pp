define packages::pkgdmg($version, $private=false, $dmgname=undef) {
        case $dmgname {
                undef: {
                         $filename = "${name}-${version}.dmg"
                }
                default: {
                    $filename = $dmgname
                }
        }

    case $private {
        true: {
            $source = "http://repos/repos/private/DMGs/$filename"
        }
        default: {
            $source = "http://repos/repos/DMGs/$filename"
        }
    }

    package {
        $filename:
            provider => pkgdmg,
            ensure => installed,
            source => $source;
    }
}


