# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::qemu_kvm {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        'qemu-kvm':
                            ensure => '1.0+noroms-0ubuntu13';
                    }
                }
                16.04: {
                    package {
                        'qemu-kvm':
                            ensure => '1:2.5+dfsg-5ubuntu10.9';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
