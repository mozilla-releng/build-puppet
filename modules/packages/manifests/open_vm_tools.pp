# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::open_vm_tools {

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    package {
                        'open-vm-tools':
                            ensure => '2:10.0.7-3227872-5ubuntu1~16.04.1'
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            fail('Cannot install open-vm-tools on this platform')
        }
    }
}
