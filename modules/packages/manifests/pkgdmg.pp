define packages::pkgdmg($version) {
    $dmgname = "${name}-${version}.dmg"

    package {
        $dmgname:
            provider => pkgdmg,
            ensure => installed,
            source => "http://repos/repos/DMGs/$dmgname";
    }
}
