# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::git {
    anchor {
        'packages::mozilla::git::begin': ;
        'packages::mozilla::git::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::git::begin'] ->
            package {
                "mozilla-git":
                    ensure => '1.7.9.4-3.el6';
            } -> Anchor['packages::mozilla::git::end']
        }
        Darwin: {
            Anchor['packages::mozilla::git::begin'] ->
            packages::pkgdmg {
                git:
                    version => "1.7.9.4-1";
            } -> Anchor['packages::mozilla::git::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
