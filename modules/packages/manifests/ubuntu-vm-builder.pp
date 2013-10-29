# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::ubuntu-vm-builder{
    case $::operatingsystem {
        Ubuntu: {
            package {
                "ubuntu-vm-builder":
                    ensure => "0.12.4+bzr477-0ubuntu1";
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
