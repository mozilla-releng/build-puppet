# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::java {
    anchor {
        'packages::java::begin': ;
        'packages::java::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            # The dmg is available from https://www.java.com/en/download/manual.jsp
            Anchor['packages::java::begin'] ->
            packages::pkgdmg {
                "java":
                   version => "7.0.600",
                   os_version_specific => false,
            } -> Anchor['packages::java::end']
        }
        Ubuntu: {
            package {
                "openjdk-7-jre":
                    ensure => latest;

                # Install icedtea-netx for the javaws command
                "icedtea-netx":
                    ensure => latest,
                    require => Package["openjdk-7-jre"];
            }
        }
        default: {
            fail("Cannot install on $::operatingsystem")
        }
    }
}
