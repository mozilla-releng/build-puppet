# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::wget {
    anchor {
        'packages::wget::begin': ;
        'packages::wget::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::wget::begin'] ->
            package {
                "wget":
                    ensure => '1.15-2.el6';  # hand-compiled; see .spec
            } -> Anchor['packages::wget::end']
        }
        Ubuntu: {
            Anchor['packages::wget::begin'] ->
            package {
                "wget":
                    ensure => '1.13.4-2ubuntu1';
            } -> Anchor['packages::wget::end']
        }
        Darwin: {
            Anchor['packages::wget::begin'] ->
            packages::pkgdmg {
                wget:
                    version => "1.15-2";
            } -> Anchor['packages::wget::end']
        }
        Windows: {
            # on Windows, we use the wget that ships with MozillaBuild
            include packages::mozilla::mozilla_build
            Anchor['packages::wget::begin'] ->
            Class['packages::mozilla::mozilla_build']
            -> Anchor['packages::wget::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
