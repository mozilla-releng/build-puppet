# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
