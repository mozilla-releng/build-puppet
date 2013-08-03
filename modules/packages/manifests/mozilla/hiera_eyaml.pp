# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::hiera_eyaml {
    case $::operatingsystem {
        CentOS: {
            package {
                # this gem requires rubygem-trollop and rubygem-highline
                "rubygem-hiera-eyaml":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}

