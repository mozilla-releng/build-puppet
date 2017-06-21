# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define packages::pkgdmg(
    $version,
    $private=false,
    $dmgname=undef,
    $os_version_specific=true
) {
    include ::config
    case $dmgname {
        undef: {
            $filename = "${name}-${version}.dmg"
        }
        default: {
            $filename = $dmgname
        }
    }

    $p = $private ? {
        true  => '/private',
        false => ''
    }

    $v = $os_version_specific ? {
        true  => "/${::macosx_productversion_major}",
        false => ''
    }

    $source = "https://${::config::data_server}/repos${p}/DMGs${v}/${filename}"

    package {
        $filename:
            ensure   => installed,
            provider => pkgdmg,
            source   => $source;
    }
}
