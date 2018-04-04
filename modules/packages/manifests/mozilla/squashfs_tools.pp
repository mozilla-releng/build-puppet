# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::squashfs_tools {
    case $operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['squashfs-tools'])
            package {
                'mozilla-squashfs-tools':
                    ensure => '4.3-0.21.gitaae0aff4.el6';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
