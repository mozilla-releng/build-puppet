# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::kvm {
    include concat::setup
    case $::operatingsystem {
        Ubuntu: {
          case $::operatingsystemrelease {
            '16.04': {
                concat {
                    '/etc/modprobe.d/blacklist.conf':
                        owner => root,
                        group => root,
                        mode  => filemode(0644);
                }
                # need at least one fragment, or concat will fail:
                concat::fragment {
                    'blacklist kvm':
                        target  => '/etc/modprobe.d/blacklist.conf',
                        content => "blacklist kvm\nblacklist kvm-intel\n"
                }
            }
          }
        }
    }
}
