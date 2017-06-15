# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::server inherits disableservices::common {
    # This class disables unnecessary services on the server
    case $::operatingsystem {
        Darwin : {
            service {
                # coreaudiod
                'com.apple.audio.coreaudiod':
                    ensure => stopped,
                    enable => false,
            }
        }
    }
}
