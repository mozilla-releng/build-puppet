# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::kvm {
    case $::operatingsystem {
        Ubuntu: {
          case $::operatingsystemrelease {
            '16.04': {
                file_line { 'blacklist kvm':
                    ensure => present,
                    path   => '/etc/modprobe.d/blacklist.conf',
                    line   => "blacklist kvm"
                }
                file_line { 'blacklist kvm-intel':
                    ensure => present,
                    path   => '/etc/modprobe.d/blacklist.conf',
                    line   => 'blacklist kvm-intel'
                }
            }
          }
        }
    }
}
