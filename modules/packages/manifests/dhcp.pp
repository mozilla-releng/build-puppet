# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Update dhcp client on CentOS systems for CVE-2018-1111
# https://lists.centos.org/pipermail/centos-announce/2018-May/022831.html
class packages::dhcp {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['dhcp'])
            package {
                ['dhcp', 'dhcp-common']:
                    ensure => '4.1.1-53.P1.el6.centos.4';
            }
        }

        default: {
            # Only RedHat/CentOS with the NetworkManager script is affected
        }
    }
}
