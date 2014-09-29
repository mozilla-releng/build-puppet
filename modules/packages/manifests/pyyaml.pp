# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::pyyaml {
    case $::operatingsystem {
        CentOS: {
            package {
                "PyYAML":
                    ensure => "3.09-5.el6";
            }
        }

        Ubuntu: {
            package {
                "python-yaml":
                    ensure => present;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
