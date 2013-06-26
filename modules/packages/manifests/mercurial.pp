# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mercurial {
    case $::operatingsystem {
        CentOS: {
            package {
                "mercurial":
                    ensure => latest;
            }
        }
        Ubuntu: {
            package {
                ["mercurial", "mercurial-common"]:
                    ensure => "2.0.2-1ubuntu1";
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
